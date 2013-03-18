class UserRole < ActiveRecord::Base
  attr_readonly :signup_token
  attr_accessor :enable_content_creation
  attr_accessible :company_id, 
    :name,  
    :enable_administration,
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
  
  private    
    def random_alphanumeric(size=15)
      (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    end
end
