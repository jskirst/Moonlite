class CompletedTask < ActiveRecord::Base
	attr_accessible :task_id, :status_id, :quiz_session, :updated_at
	
	belongs_to :user
	belongs_to :task
	has_one :section, :through => :task
	has_one :path, :through => :section
	has_one :category, :through => :path
	
	validates :user_id, :presence => true
	validates :task_id, :presence => true
	validates :status_id, :presence => true

  validate :user_enrolled_in_path
  
  private
    def user_enrolled_in_path
			unless user.nil? || task.nil? || user.enrolled?(task.path)
				errors[:base] << "User must be enrolled in the path."
      end
    end
  
end
