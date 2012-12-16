class Section < ActiveRecord::Base
  attr_protected :path_id
  attr_accessible :name, 
    :instructions, 
    :position,
    :points_to_unlock,
    :is_published
  
  belongs_to :path
  has_many :tasks, dependent: :destroy
  has_many :completed_tasks, through: :tasks, source: :completed_tasks
  
  validates :name, length: { within: 1..255 }
  validates :path_id, presence: true
    
  before_create { self.position = get_next_position_for_path }
  
  def randomize_tasks
    old_task_array = tasks.all(:order => "position ASC").to_a
    unless old_task_array.size == 1
      new_task_array = old_task_array.shuffle
      until new_task_array != old_task_array
        new_task_array = old_task_array.shuffle
      end
      
      new_task_array.each_index do |ti|
        t = new_task_array[ti]
        t.position = ti
        t.save
      end
    end
  end
      
  def next_task(user)
    return get_next_unfinished_task(user)
  end
  
  def completed?(user)
    return true if remaining_tasks(user) <= 0
    return false
  end
  
  def remaining_tasks(user)
    unless self.is_published == false
      return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).count
    else
      return 0
    end
  end
  
  def user_streak(user)
    user_completed_tasks = completed_tasks.where("user_id = ?", user.id).all(:order => "id DESC")
    streak = 0
    logger.debug "Computing streak."
    logger.debug user_completed_tasks.to_yaml
    unless user_completed_tasks.empty?
      current_task_id = user_completed_tasks.first.task_id
      last_completed_status_id = user_completed_tasks.first.status_id
      logger.debug current_task_id.to_yaml
      logger.debug last_completed_status_id.to_s
      if last_completed_status_id == 1
        streak = 1
        user_completed_tasks.each do |t|
          first_task_id ||= t.task_id
          if t.id != first_task_id && t.status_id == 1
            streak += 1
          elsif t.status_id == 0
            streak -= 1 unless streak == 0
            break
          end
        end
      elsif last_completed_status_id == 0
        logger.debug "COMPUTING NEGATIVE STREAK!"
        user_completed_tasks.each do |t|
          unless t.status_id == 0 && t.task_id == current_task_id
            break;
          else
            streak -= 1
          end
        end
      end
    end
    return streak
  end
  
  def quiz_complete?(user)
    incomplete_tasks = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id) and tasks.answer_type in (?)", user.id, [1,2]])
    return incomplete_tasks.size == 0
  end
  
  def challenge_tasks
    return tasks.where("answer_type in (?)", [0])
  end
  
  def core_tasks
    return tasks.where("answer_type in (?)", [1,2])
  end
  
  def achievement_tasks
    return tasks.where("answer_type in (?)", [3])
  end
  
  def unlocked?(user)
    enrollment = user.enrollments.find_by_path_id(self.path_id)
    return false if enrollment.nil?
    return enrollment.total_points.to_i >= self.points_to_unlock
  end
  
  def points_until_unlock(enrollment)
    self.points_to_unlock.to_i - enrollment.total_points.to_i
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
    def get_next_unfinished_task(user)
      previous_task = tasks.joins(:completed_tasks).where(["completed_tasks.user_id = ?", user.id]).last(:order => "position ASC")
      previous_task_position = previous_task.nil? ? 0 : previous_task.position
      if user.company_id > 1
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).first(:order => "position ASC")
      else
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id) and tasks.answer_type not in (0,3)", user.id]).first(:order => "position ASC")
      end
    end
  
    def get_next_position_for_path
     return (path.sections.last.position + 1) unless path.sections.empty?
     return 1
    end
end
