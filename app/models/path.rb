class Path < ActiveRecord::Base
	attr_accessible :name, :description, :company_id, :purchased_path_id, :image_url, :is_public, :is_published, :is_purchaseable, :category_type
	
	belongs_to :user
	belongs_to :company
	has_many :sections, :dependent => :destroy
	has_many :tasks, :through => :sections, :conditions => ["sections.is_published = ?", true]
	has_many :achievements, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
  has_many :enrolled_users, :through => :enrollments, :source => :user
	has_many :info_resources, :dependent => :destroy
	
	validates :name, 
		:presence => true,
		:length		=> { :within => 2..140 }
	
	validates :description,
		:length		=> { :maximum => 2500 }
	
	validates :user_id, :presence => true
	
	validate :company_id, :if => :user_belongs_to_company
  
  before_save :check_image_url
	
	#default_scope :order => 'paths.created_at DESC'
  
  def self.with_category_type(type, excluded_id = -1, order = "id DESC")
    return Path.where("is_published = ? and category_type = ? and id != ?", true, "#{type}", excluded_id).all(:order => order)
  end
  
  def self.with_name_like(name)
    return Path.where("is_published = ? and name LIKE ?", true, "%#{name}%")
  end
  
  def self.category_types
    return ["Professional", "Just for fun", "Periodicals"]
  end
  
  def self.get_category_type_id(str)
    types = category_types
    i = types.index(str)
    return i unless i < 0
    return nil
  end
  
  def self.similar_paths(path)
    unless path.nil?
      return Path.with_category_type(path.category_type, path.id, "id DESC")
    else
      return Path.with_category_type(0)
    end
  end
  
  def self.suggested_paths(user, excluded_path_id = -1)
    return Path.with_category_type(0, excluded_path_id, "id ASC")
  end
  
  def current_section(current_user)
		last_task = current_user.completed_tasks.includes(:section).where(["sections.path_id = ?", self.id]).first(:order => "sections.position DESC")
    logger.debug last_task
    return sections.first if last_task.nil?
		return last_task.section
  end
  
  def next_section(section=nil)
    return sections.where(["position > ? and is_published = ?", section.position, true]).first
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
  
  def enrolled_user_count
    return enrollments.count
  end
  
  def difficulty_rating
    task_count = tasks.count
    return "Easy" if task_count < 50
    return "Medium" if task_count < 150
    return "Hard"
  end
  
  private
    def check_image_url
      unless self.image_url.nil?
        self.image_url = nil if self.image_url.length < 9
      end
    end
end