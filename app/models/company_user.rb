class CompanyUser < ActiveRecord::Base
	attr_accessible :user_id, 
		:company_id, 
		:email, 
		:token1, 
		:token2,
		:is_admin
	
	belongs_to :user
	belongs_to :company
	
	before_save :set_tokens
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :company_id, 
		:presence => true
	validates :email,		
		:presence 	=> true,
		:format		=> { :with => email_regex },
		:uniqueness => { :case_sensitive => false }
	validates :user_id,
		:allow_nil => true,
		:uniqueness => true
	validates :is_admin,
		:inclusion => { :in => [true, false] }
	
	def send_invitation_email
		email_details = { :email => self.email, :token1 => self.token1 }
		Mailer.welcome(email_details).deliver
	end
	
	private
		def set_tokens
			if(self.token1 == nil)
				self.token1 = random_alphanumeric
				self.token2 = random_alphanumeric
			end
		end
		
		def random_alphanumeric(size=15)
			(1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
		end
end
