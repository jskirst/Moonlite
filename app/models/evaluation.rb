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
  
  has_many :evaluation_users
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
  
  after_create do
    selected_paths.each do |id,checked|
      evaluation_paths.create!(path_id: id)
    end
  end
  
  def next_core_task(user, path) next_task(user, path, [Task::EXACT, Task::MULTIPLE]) end
  def next_challenge_task(user, path) next_task(user, path, [Task::CREATIVE]) end
  def next_task(user, path, answer_types)
    return Task.joins("INNER JOIN sections on sections.id=tasks.section_id and sections.published_at is not NULL")
      .joins("INNER JOIN paths on paths.id=sections.path_id and paths.id = #{path.id}")
      .where("tasks.locked_at is NULL and tasks.reviewed_at is not NULL and answer_type in (?)", answer_types)
      .where("NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id)
      .first
  end
end