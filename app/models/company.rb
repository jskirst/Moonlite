class Company < ActiveRecord::Base
	attr_accessible :name, :enable_company_store, :enable_leaderboard, :enable_tour, :enable_dashboard
	
	has_many :users
	has_many :rewards
	has_many :paths
	has_many :categories
	
	after_create :set_owner
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 100 }
		
	private
		def set_owner
			self.owner_id = self.id
			self.save!
		end
end
