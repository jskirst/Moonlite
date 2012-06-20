class CompletedTask < ActiveRecord::Base
  attr_accessible :task_id, :submitted_answer_id, :answer_id, :status_id, :quiz_session, :updated_at, :points_awarded, :answer
  
  belongs_to :user
  belongs_to :task
  belongs_to :submitted_answer
  belongs_to :choice_answer
  has_one :section, :through => :task
  has_one :path, :through => :section
  has_one :category, :through => :path
  
  validates :user_id, :presence => true
  validates :task_id, :presence => true
  validates :status_id, :presence => true

  validate :user_enrolled_in_path
  
  def user_submitted_answer
    return nil if submitted_answer.nil
    return submitted_answer.content
  end
  
  private
    def user_enrolled_in_path
      unless user.nil? || task.nil? || user.enrolled?(task.path)
        errors[:base] << "User must be enrolled in the path."
      end
    end
  
end
