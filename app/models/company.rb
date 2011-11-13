class Company < ActiveRecord::Base
	attr_accessible :name
	
	has_many :company_users
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 100 }
end
