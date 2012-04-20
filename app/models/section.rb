class Section < ActiveRecord::Base
	attr_accessible :name, :instructions, :position, :is_published, :image_url,
		:content_type, :hidden_content, :enable_skip_content
	
	before_create :set_position
	
	belongs_to :path
	has_many :tasks, :dependent => :destroy
	has_many :completed_tasks, :through => :tasks, :source => :completed_tasks
  has_many :info_resources, :dependent => :destroy
	
	validates :name, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :instructions,
		:length			=> { :maximum => 1000000 }
	
	validates :path_id, 
		:presence 		=> true
    
  before_save :check_image_url
		
	default_scope :order => 'sections.position ASC'
  
  def randomize_tasks
    task_array = []
    tasks.each do |t|
      task_array << t
    end
    task_array = task_array.shuffle
    task_array.each_index do |ti|
      t = task_array[ti]
      t.position = ti
      t.save
    end
  end
  
  def pic
		if self.image_url != nil
			return self.image_url
		else
			return "/images/default_section_pic.jpg"
		end
	end
		
	def next_task(user)
    next_task = get_next_unfinished_task(user)
    next_task = get_next_incorrectly_finished_task(user) if next_task.nil?
    return next_task
	end
  
  def completed?(user)
    return true if remaining_tasks(user) <= 0
    return false
  end
	
	def remaining_tasks(user)
    number_of_completed_tasks = completed_tasks.where(["completed_tasks.user_id = ? and status_id = 1", user.id]).count(:distinct => "completed_tasks.task_id")
    number_of_remaining_tasks = tasks.size - number_of_completed_tasks
    return number_of_remaining_tasks
	end
  
  def user_streak(user)
    user_completed_tasks = completed_tasks.where("user_id = ?", user.id).all.reverse
    streak = 0
    user_completed_tasks.each do |t|
      unless t.status_id == 1
        break;
      else
        streak += 1
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
        other_answers = user.completed_tasks.where(["completed_tasks.task_id = ? and status_id = 1", a.id]).count
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
