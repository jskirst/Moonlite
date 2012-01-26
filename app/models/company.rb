class Company < ActiveRecord::Base
	attr_accessible :name, :enable_company_store
	
	has_many :company_users
	has_many :users, :through => :company_users
	has_many :rewards
	has_many :paths
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 100 }
end
