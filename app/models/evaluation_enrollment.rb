class EvaluationEnrollment < ActiveRecord::Base
  attr_accessible :evaluation_id, :user_id, :submitted_at
  
  belongs_to :evaluation
  belongs_to :user
  has_one :group, through: :evaluation
  
  def submitted?() not self.submitted_at.nil? end
end