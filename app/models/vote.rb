class Vote < ActiveRecord::Base
  attr_accessible :submitted_answer_id
  
  belongs_to :submitted_answer
  belongs_to :user
  
  validates :submitted_answer_id, :presence => true
  validates :user_id, :presence => true
  
  validate :check_for_duplicate
  
  private
    def check_for_duplicate
      if Vote.find_by_submitted_answer_id_and_user_id(self.submitted_answer_id, self.user_id)
        errors[:base] << "You cannot double cast a vote."
      end
    end
end
