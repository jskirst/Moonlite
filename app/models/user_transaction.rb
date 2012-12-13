class UserTransaction < ActiveRecord::Base
  #TODO: make all fields read only
  attr_accessible :user_id,
    :owner_id,
    :owner_type, 
    :task_id, 
    :path_id, 
    :amount, 
    :status
  
  belongs_to :user
  belongs_to :owner, polymorphic: true
  
  validates :user_id, presence: true
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :amount, presence: true
  validates :status, presence: true
end
