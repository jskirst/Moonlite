class UserRole < ActiveRecord::Base
  attr_readonly :signup_token
  attr_accessible :company_id, 
    :name,  
    :enable_administration,
    :enable_rewards,
    :enable_leaderboard,
    :enable_dashboard,
    :enable_tour,
    :enable_browsing,
    :enable_comments,
    :enable_news,
    :enable_feedback,
    :enable_achievements,
    :enable_recommendations,
    :enable_printer_friendly,
    :enable_user_creation,
    :enable_auto_enroll,
    :enable_one_signup,
    :enable_collaboration,
    :enable_auto_generate,
    :signup_token
  
  has_many :users
  belongs_to :company
  
  validates :company_id, presence: true
  validates :name, length: { within: 1..255 }
  
  before_create { self.signup_token = random_alphanumeric }
  before_destroy { users.empty? }
  
  def signup_link
    if Rails.env.production?
      return "http://www.metabright.com/companies/#{self.signup_token}/join"
    else
      return "http://localhost:3000/companies/#{self.signup_token}/join"
    end
  end
  
  def send_invitation_email(email)
    email_details = { :email => email, :signup_link => self.signup_link }
    Mailer.welcome(email_details).deliver
  end
  
  private    
    def random_alphanumeric(size=15)
      (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    end
end
