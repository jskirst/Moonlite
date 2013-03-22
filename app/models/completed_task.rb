class CompletedTask < ActiveRecord::Base
  CORRECT_POINTS = 100
  
  attr_readonly :task_id
  attr_protected :updated_at, :answer_id, :points_awarded, :submitted_answer_id, :enrollment_id, :award_points
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
  
  after_save do
    if correct? && award_points
      user.award_points(self, self.points_awarded)
    end
  end
  
  delegate :content, :url, :title, :description, :caption, :image_url, :site_name, to: :submitted_answer
  
  def reviewed?
    return true if submitted_answer.nil?
    return submitted_answer.reviewed?
  end
  def incomplete?() status_id == Answer::INCOMPLETE end
  def correct?() status_id == Answer::CORRECT end
  def incorrect?() status_id == Answer::INCORRECT end
end
