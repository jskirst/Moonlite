class Vote < ActiveRecord::Base
  attr_readonly :submitted_answer_id
  
  belongs_to :submitted_answer
  belongs_to :user
  
  validates :submitted_answer_id, presence: true, uniqueness: { scope: :user_id }
  validates :user_id, presence: true
end
