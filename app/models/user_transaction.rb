class UserTransaction < ActiveRecord::Base
  attr_accessible :user_id, 
    :task_id, 
    :reward_id,
    :path_id, 
    :amount, 
    :status
  
  belongs_to :user
  belongs_to :task
  belongs_to :reward
  belongs_to :path
  
  validates :user_id, 
    :presence => true
  validates :amount,
    :presence   => true
  validates :status,
    :presence   => true
    
  validate :has_task_or_reward_or_path
  before_create :user_enrolled_in_path

  private
    def user_enrolled_in_path
      unless user.nil? || task.nil? || !reward.nil? || !path.nil? || user.enrolled?(task.path)
        errors[:base] << "User must be enrolled in the path."
      end
    end
  
    def has_task_or_reward_or_path
      if task.nil? && reward.nil? && path.nil?
        errors[:base] << "Transaction requires one of the following: Task, Reward or Path."
      elsif !task.nil? && !(reward.nil? && path.nil?)
        errors[:base] << "Transaction requires one of the following: Task, Reward or Path."
      elsif !reward.nil? && !(task.nil? && path.nil?)
        errors[:base] << "Transaction requires one of the following: Task, Reward or Path."
      elsif !path.nil? && !(reward.nil? && task.nil?)
        errors[:base] << "Transaction requires one of the following: Task, Reward or Path."
      end
    end
end
