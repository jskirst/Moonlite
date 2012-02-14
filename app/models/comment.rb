class Comment < ActiveRecord::Base
  attr_accessible :task_id, :content
  
  belongs_to :user
  belongs_to :task

  validates :user_id, 
	  :presence => true
  validates :task_id, 
	  :presence => true
  validates :content, 
	  :presence => true,
    :length => { :within => 1..255 }
  validate :user_enrolled_in_path
  
  private
    def user_enrolled_in_path
			unless task.nil? || user.enrolled?(task.path)
				errors[:base] << "User must be enrolled in the path."
      end
    end
end
