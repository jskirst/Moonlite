class Company < ActiveRecord::Base
	attr_accessible :name
	
	has_many :company_users
	has_many :users, :through => :company_users
	has_many :rewards
	has_many :paths
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 100 }
end
