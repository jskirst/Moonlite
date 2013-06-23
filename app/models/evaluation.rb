class Evaluation < ActiveRecord::Base
  attr_accessor :selected_paths
  attr_readonly :group_id
  attr_protected :user_id, :group_id
  attr_accessible :title,
    :company,
    :link,
    :permalink,
    :selected_paths,
    :closed_at
  
  belongs_to :user
  belongs_to :group
  
  has_many :evaluation_enrollments
  has_many :users, through: :evaluation_enrollments
  has_many :evaluation_paths
  has_many :paths, through: :evaluation_paths
  
  validates_presence_of :group_id
  validates_presence_of :user_id
  validates_presence_of :company
  validates_presence_of :title
  validate do
    if new_record? and (selected_paths.nil? or selected_paths.empty?)
      errors[:base] << "You must select at least one skill to evaluate your candidates on before creating an evaluation."
    end
  end
  
  before_create do
    self.permalink = SecureRandom.hex(6)
  end
  
  after_save :update_evaluation_paths
  
  def update_evaluation_paths
    return true if selected_paths.nil? or selected_paths.empty?
    available_paths = (Persona.first.paths.to_a + group.paths.to_a).collect(&:id)
    selected_ids = selected_paths.keys.map{ |id| id.to_i }
    existing_ids = []
    evaluation_paths.each do |ep|
      existing_ids << ep.path_id
      ep.destroy unless selected_ids.include?(ep.path_id)
    end
    
    selected_ids.each do |id|
      raise "Access Denied: Unavailable Path [#{id}]" unless available_paths.include?(id)
      evaluation_paths.create!(path_id: id) unless existing_ids.include?(id)
    end 
    
    raise "No evaluations selected" unless evaluation_paths.count > 0
  end
  
  def next_task(user, path)
    type = [Task::MULTIPLE, Task::EXACT]
    if completed_count(user, path, type) < 30
      task = next_task_of_type(user, path, type)
      return next_task if next_task
    end
    
    type = [Task::CREATIVE]
    if completed_count(user, path, type) < 5
      return next_task_of_type(user, path, type)
    end
  end
  def next_task_of_type(user, path, answer_types)
    return Task.where("tasks.path_id = ?", path.id)
      .where("tasks.locked_at is NULL and tasks.reviewed_at is not NULL and answer_type in (?)", answer_types)
      .where("NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id and completed_tasks.deleted_at is NULL)", user.id)
      .first
  end
  
  def completed_count(user, path, types)
    return user.completed_tasks.joins(:task => :path)
      .where("paths.id = ?", path.id)
      .where("tasks.answer_type in (?)", types)
      .count
  end
end