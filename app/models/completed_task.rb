class CompletedTask < ActiveRecord::Base
  CORRECT_POINTS = 100
  
  attr_readonly :task_id
  attr_protected :updated_at, :answer_id, :points_awarded, :submitted_answer_id, :award_points
  attr_accessible :status_id, :task_id
  attr_accessor :award_points
  
  belongs_to :user
  belongs_to :task
  belongs_to :submitted_answer, dependent: :destroy
  belongs_to :chosen_answer, class_name: "Answer"
  has_one :section, through: :task
  has_one :path, through: :section
  
  validates :user_id, presence: true
  validates :task_id, presence: true
  validates_uniqueness_of :task_id, scope: :user_id
  validates :status_id, presence: true
  
  before_save do
    if status_id == Answer::CORRECT && (self.new_record? || self.points_awarded.nil?)
      unless self.points_awarded
        self.points_awarded = CORRECT_POINTS
      end
      self.award_points = true
    end
  end
  after_save do
    if award_points
      user.award_points(self, self.points_awarded)
    end
  end
end
