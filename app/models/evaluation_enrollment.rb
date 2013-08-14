class EvaluationEnrollment < ActiveRecord::Base
  attr_accessible :evaluation_id, :user_id, :submitted_at
  
  belongs_to :evaluation
  belongs_to :user
  has_one :group, through: :evaluation
  
  def submitted?() not self.submitted_at.nil? end

  # Mail Alert

  def self.new_submissions(time)
    where("submitted_at > ?", time)
  end

  def send_submission_email(deliver = false)
    m = GroupMailer.submission(self)
    m.deliver if deliver
  end

  def self.send_all_welcome_emails(time, deliver = false)
    new_submissions(time).each { |g| g.send_submission_email(deliver) }
  end
end