class Company < ActiveRecord::Base
	attr_accessor :admin_email
	attr_accessible :name, :enable_company_store, :enable_leaderboard, :enable_tour, :enable_dashboard, 
		:enable_recommendations, :enable_comments, :enable_printer_friendly, :enable_feedback, 
		:enable_achievements, :enable_browsing, :enable_news, :enable_user_creation,
		:enable_auto_enroll, :enable_collaboration, :enable_one_signup, :signup_token
	
	has_many :users
	has_many :rewards
	has_many :paths
	has_many :categories
	
	before_create :set_signup_token
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 100 }
		
	def reset_signup_link
		self.signup_token = random_alphanumeric
	end
	
	def one_signup_link
		return ["onesign", self.signup_token].join("/")
	end
		
	private
		def set_signup_token
			if(self.signup_token == nil)
				self.signup_token = random_alphanumeric
			end
		end
		
		def random_alphanumeric(size=15)
			(1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
		end
end
