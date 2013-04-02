class Section < ActiveRecord::Base
  attr_protected :path_id, :published_at
  attr_accessible :name, 
    :instructions, 
    :position,
    :points_to_unlock
  
  belongs_to :path
  has_many :tasks, dependent: :destroy
  has_many :completed_tasks, through: :tasks, source: :completed_tasks
  
  validates :name, length: { within: 1..255 }
  validates :path_id, presence: true
    
  before_create { self.position = get_next_position_for_path }
  before_save { self.points_to_unlock = 0 if self.points_to_unlock.nil? }
      
  def next_task(user = nil, exclude_first = false, type = Task::MULTIPLE)
    if user.nil?
      next_tasks = tasks.where("locked_at is ? and answer_type = ?", nil, type)
    else
      next_tasks = tasks.where("locked_at is ? and answer_type = ?", nil, type)
        .where("NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id)
    end
    
    unless exclude_first
      next_tasks.order("position DESC").first
    else
      next_tasks.order("position DESC").first(2).first
    end
  end
  
  def completed?(user) remaining_tasks(user, Task::MULTIPLE) <= 0 end
  
  def remaining_tasks(user, type = nil)
    unless self.published_at.nil?
      if type
        tasks.where("NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id)
          .where("tasks.answer_type = ?", type)
          .count
      else
        tasks.where("NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id).count
      end
    else
      return 0
    end
  end
  
  def challenge_tasks() tasks.where("answer_type in (?)", [0]) end
  def core_tasks() tasks.where("answer_type in (?)", [1,2]) end
  def achievement_tasks() tasks.where("answer_type in (?)", [3]) end
  
  def unlocked?(user)
    enrollment = user.enrollments.find_by_path_id(self.path_id)
    return points_until_unlock(enrollment) <= 0
  end
  
  def points_until_unlock(enrollment)
    return 0 if self.points_to_unlock.nil?
    return self.points_to_unlock if enrollment.nil? or enrollment.total_points.nil?
    return self.points_to_unlock.to_i - enrollment.total_points.to_i
  end
  
  def percentage_complete(user)
    completed_task_count = self.completed_tasks.where("user_id = ?", user.id).size.to_f
    return 0 if completed_task_count == 0
    return ((completed_task_count / tasks.size.to_f) * 100).to_i
  end
  
  def points_earned(user)
    user_completed_tasks = self.completed_tasks.where("user_id = ? and status_id >= 0 and points_awarded is not ?", user.id, nil)
    return 0 if user_completed_tasks.size == 0
    return user_completed_tasks.collect(&:points_awarded).reduce(0, :+)
  end
    
  private
    def get_next_position_for_path() path.sections.empty? ? 1 : (path.sections.last.position + 1) end
end
