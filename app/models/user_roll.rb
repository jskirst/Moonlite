class UserRoll < ActiveRecord::Base
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
	
	validates :name,
	:length			=> { :within => 1..255 }
	
	before_create :set_signup_token
	before_destroy :any_users_left?
	
	def signup_link
		if Rails.env.production?
			return "http://www.projectmoonlite.com/companies/#{self.signup_token}/join"
		else
			return "http://localhost:3000/companies/#{self.signup_token}/join"
		end
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
		
		def any_users_left?
			return users.empty?
		end
end
