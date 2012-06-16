class Section < ActiveRecord::Base
  attr_protected :path_id
  attr_accessible :name, :instructions, :position, :is_published, :image_url,
    :content_type, :hidden_content, :enable_skip_content
  
  before_create :set_position
  
  belongs_to :path
  has_many :tasks, :dependent => :destroy
  has_many :completed_tasks, :through => :tasks, :source => :completed_tasks
  has_many :info_resources, :dependent => :destroy
  
  validates :name, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :instructions,
    :length      => { :maximum => 1000000 }
  
  validates :path_id, 
    :presence     => true
    
  before_save :check_image_url
  
  def randomize_tasks
    old_task_array = tasks_to_array
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
  
  def tasks_to_array
    ary = []
    tasks.all(:order => "position ASC").each do |t|
      ary << t
    end
    return ary
  end
  
  def has_custom_image?
    return !self.image_url.nil?
  end
  
  def pic
    if self.image_url != nil
      return self.image_url
    else
      return "/images/default_section_pic.jpg"
    end
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
  
  #correct answers is really the number of questions without an incorrect answer
  def percentage_correct(user = nil)
    if user.nil?
      number_of_tasks = completed_tasks.where("status_id = ?", 1).size
      correct_answers = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.task_id = tasks.id and completed_tasks.status_id = 0)"]).count
      return 0 if correct_answers == 0 || number_of_tasks == 0
    else
      number_of_tasks = tasks.size
      correct_answers = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id and completed_tasks.status_id = 0)", user.id]).count
      return 0 if correct_answers == 0 || number_of_tasks == 0
    end
    return ((correct_answers.to_f / number_of_tasks.to_f) * 100).to_i
  end
  
  def user_streak(user)
    user_completed_tasks = completed_tasks.where("user_id = ?", user.id).all(:order => "id DESC")
    streak = 0
    unless user_completed_tasks.empty?
      current_task_id = user_completed_tasks.first.task_id
      last_completed_status_id = user_completed_tasks.first.status_id == 1
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
    
  private
    def check_image_url
      unless self.image_url.nil?
        self.image_url = nil if self.image_url.length < 9
      end
    end
  
    def get_next_unfinished_task(user)
      previous_task = tasks.joins(:completed_tasks).where(["completed_tasks.user_id = ?", user.id]).last(:order => "position ASC")
      previous_task_position = previous_task.nil? ? 0 : previous_task.position
      return tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).first(:order => "position ASC")
    end
    
    def get_next_incorrectly_finished_task(user)
      incorrect_answers = tasks.joins(:completed_tasks).where(["status_id = 0 and user_id = ?", user.id]).all(:order => "position ASC")
      incorrect_answers.each do |a|
        other_answers = user.completed_tasks.where(["completed_tasks.task_id = ? and (status_id = 1 or status_id = 2)", a.id]).count
        if other_answers == 0
          return a
        end
      end
      return nil
    end
  
    def set_position
      self.position = get_next_position_for_path
    end
    
    def get_next_position_for_path
      unless path.sections.empty?
        return path.sections.last.position + 1
      else
        return 1
      end
    end
end
