class Section < ActiveRecord::Base
  attr_protected :path_id, :is_published
  attr_accessible :name, 
    :instructions, 
    :position, 
    :image_url,
    :content_type, 
    :enable_skip_content,
    :points_to_unlock
  
  belongs_to :path
  has_many :tasks, dependent: :destroy
  has_many :completed_tasks, through: :tasks, source: :completed_tasks
  has_many :stored_resources, as: :owner
  
  validates :name, length: { within: 1..255 }
  validates :instructions, length: { maximum: 1000000 }
  validates :path_id, presence: true
    
  before_create { self.position = get_next_position_for_path }
  before_save { self.image_url = nil if ( self.image_url && self.image_url.length < 9) }
  
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
  
  def has_custom_image?
    return !self.image_url.nil?
  end
  
  def pic
    return self.image_url if self.image_url != nil
    return "/images/default_section_pic.jpg"
  end
    
  def next_task(user)
    if path.enable_retakes
      next_task = get_next_incorrectly_finished_task(user)
      next_task = get_next_unfinished_task(user) if next_task.nil?
    else
      next_task = get_next_unfinished_task(user)
    end
    return next_task
  end
  
  def completed?(user)
    return true if remaining_tasks(user) <= 0
    return false
  end
  
  def remaining_tasks(user)
    unless self.is_published == false
      if path.enable_retakes
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id and (completed_tasks.status_id = ? or completed_tasks.status_id = ?))", user.id, 1, 2]).count
      else
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).count
      end
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
    incomplete_tasks = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id) and tasks.answer_type > ?", user.id, 0])
    return incomplete_tasks.size == 0
  end
  
  def creative_tasks
    return tasks.where("answer_type = ?", 0)
  end
  
  def core_tasks
    return tasks.where("answer_type in ?", [1,2])
  end
  
  def unlocked?(user)
    enrollment = user.enrollments.find_by_path_id(self.path_id)
    return false if enrollment.nil?
    return enrollment.total_points > self.points_to_unlock
  end
  
  def percentage_complete(user)
    return ((self.completed_tasks.where("user_id = ?", user.id).size.to_f / tasks.size.to_f) * 100).to_i
  end
    
  private
    def get_next_unfinished_task(user)
      previous_task = tasks.joins(:completed_tasks).where(["completed_tasks.user_id = ?", user.id]).last(:order => "position ASC")
      previous_task_position = previous_task.nil? ? 0 : previous_task.position
      if user.company_id > 1
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).first(:order => "position ASC")
      else
        return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id) and tasks.answer_type > 0", user.id]).first(:order => "position ASC")
      end
    end
    
    def get_next_incorrectly_finished_task(user)
      incorrect_answers = tasks.joins(:completed_tasks).where(["status_id = 0 and user_id = ?", user.id]).all(:order => "position ASC")
      incorrect_answers.each do |a|
        other_answers = user.completed_tasks.where(["completed_tasks.task_id = ? and (status_id = 1 or status_id = 2)", a.id]).count
        return a if other_answers == 0
      end
      return nil
    end
  
    def get_next_position_for_path
     return (path.sections.last.position + 1) unless path.sections.empty?
     return 1
    end
end
