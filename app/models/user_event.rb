class UserEvent < ActiveRecord::Base
  attr_accessible :path_id, :content
  
  belongs_to :user
  belongs_to :path
  has_one :company, :through => :user
  
  validates :user_id, :presence => true
  validates :path_id, :presence => true
  
  validates :content, 
    :presence     => true,
    :length      => { :within => 1..140 }
  
  validate :user_enrolled_in_path
  
  private
    def user_enrolled_in_path
      unless user.enrolled?(path)
        errors[:base] << "User must be enrolled in the path."
      end
    end
end
