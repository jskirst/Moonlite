class Section < ActiveRecord::Base
	attr_accessible :name, :instructions, :position, :is_published
	
	before_create :set_position
	
	belongs_to :path
	has_many :tasks, :dependent => :destroy
	has_many :completed_tasks, :through => :tasks, :source => :completed_tasks
  has_many :info_resources, :dependent => :destroy
	
	validates :name, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :instructions, 
		:presence 		=> true,
		:length			=> { :within => 1..2500 }
	
	validates :path_id, 
		:presence 		=> true
		
	default_scope :order => 'sections.position ASC'
		
	def next_task(user)
    next_task = get_next_unfinished_task(user)
    next_task = get_next_incorrectly_finished_task(user) if next_task.nil?
    return next_task
	end
	
	def remaining_tasks(user)
    number_of_completed_tasks = completed_tasks.where(["completed_tasks.user_id = ? and status_id = 1", user.id]).count(:distinct => "completed_tasks.task_id")
    number_of_remaining_tasks = tasks.size - number_of_completed_tasks
    return number_of_remaining_tasks
	end
		
	private
    def get_next_unfinished_task(user)
      previous_task = tasks.joins(:completed_tasks).where(["completed_tasks.user_id = ?", user.id]).last(:order => "position ASC")
      previous_task_position = previous_task.nil? ? 0 : previous_task.position
      return tasks.where(["position > ?", previous_task_position]).first(:order => "position ASC")
    end
    
    def get_next_incorrectly_finished_task(user)
      logger.debug "INCORRECTlY FINISHED"
      incorrect_answers = tasks.joins(:completed_tasks).where(["status_id = 0 and user_id = ?", user.id]).all(:order => "position ASC")
      incorrect_answers.each do |a|
        other_answers = user.completed_tasks.where(["completed_tasks.task_id = ? and status_id = 1", a.id]).count
        if other_answers == 0
          return a
        end
      end
      logger.debug "END INCORRECTlY FINISHED"
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
