class Path < ActiveRecord::Base
	attr_accessible :name, :description, :company_id, :purchased_path_id, :image_url, :is_public, :is_published, :is_purchaseable
	
	belongs_to :user
	belongs_to :company
	has_many :sections, :dependent => :destroy
	has_many :tasks, :through => :sections, :conditions => ["sections.is_published = ?", true]
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
  
  def next_section(section)
    return sections.where(["position > ?", section.position]).first
  end
	
	def path_pic
		if self.image_url != nil
			return self.image_url
		else
			return "/images/default_path_pic.jpg"
		end
	end
  
  def completed?(user)
    total_tasks = tasks.size
    completed_tasks = user.completed_tasks.includes(:path).where(["paths.id = ? and status_id = 1", self.id]).count
    return completed_tasks >= total_tasks
  end
  
  def percent_complete(user)
    total_tasks = tasks.size
    completed_tasks = user.completed_tasks.includes(:path).where(["paths.id = ? and status_id = 1", self.id]).count
    return ((completed_tasks.to_f / total_tasks.to_f) * 100).to_i
  end
	
	def user_belongs_to_company
		if company != nil
			if user.company != company
				errors[:base] << "User does not belong to this company."
			end
		end
	end
end