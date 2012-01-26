class Path < ActiveRecord::Base
	attr_accessible :name, :description, :company_id, :purchased_path_id, :image_url, :is_public, :is_published, :is_purchaseable
	
	belongs_to :user
	belongs_to :company
	has_many :sections, :dependent => :destroy
	has_many :tasks, :through => :sections
	has_many :achievements, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	has_many :info_resources, :dependent => :destroy
	
	validates :name, 
		:presence => true,
		:length		=> { :within => 2..140 }
	
	validates :description, 
		:presence => true,
		:length		=> { :within => 2..2500 }
	
	validates :user_id, :presence => true
	
	validate :company_id, :if => :user_belongs_to_company
	
	default_scope :order => 'paths.created_at DESC'
	
	def path_pic
		if self.image_url != nil
			return self.image_url
		else
			return "/images/default_path_pic.jpg"
		end
	end
	
	def user_belongs_to_company
		if company != nil
			if user.company != company
				errors[:base] << "User does not belong to this company."
			end
		end
	end
end