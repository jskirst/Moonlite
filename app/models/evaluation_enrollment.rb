class EvaluationEnrollment < ActiveRecord::Base
  attr_accessible :evaluation_id, :user_id
  
  belongs_to :evaluation
  belongs_to :user
end