class Path < ActiveRecord::Base
	def to_param
		"#{id} #{name}".parameterize
	end
	
	attr_accessible :name, :description, :company_id, :purchased_path_id, :image_url, 
		:is_public, :is_published, :is_purchaseable, :category_id, :enable_section_display,
		:default_timer, :excluded_from_leaderboards, :enable_nonlinear_sections,
		:is_locked, :enable_retakes, :game_type
	
	belongs_to :user
	belongs_to :company
	belongs_to :category
	has_many :sections, :dependent => :destroy
	has_many :tasks, :through => :sections, :conditions => ["sections.is_published = ?", true]
	has_many :enrollments, :dependent => :destroy
	has_many :enrolled_users, :through => :enrollments, :source => :user
	has_many :info_resources, :dependent => :destroy
	has_many :path_user_roles, :dependent => :destroy
	has_many :user_roles, :through => :path_user_roles
	
	validates :name, 
		:presence => true,
		:length		=> { :within => 2..140 }
	
	validates :description,
		:length		=> { :maximum => 2500 }
	
	validates :user_id, :presence => true
	
	validate :company_id, :if => :user_belongs_to_company
  
  before_save :check_image_url
	
	#default_scope :order => 'paths.created_at DESC'
  
  def self.with_category(type, user, excluded_ids = -2, order = "id DESC")
		if excluded_ids.is_a?(Integer)
			return Path.joins(:path_user_roles).where("path_user_roles.user_role_id = ? and is_published = ? and category_id = ? and paths.id != ?", user.user_role_id, true, "#{type}", excluded_ids).all(:order => order)
		else
			return Path.where("is_published = ? and category_id = ? and id NOT IN (?)", true, "#{type}", excluded_ids).all(:order => order)
		end
  end
  
  def self.with_name_like(name, user)
    return Path.joins(:path_user_roles).where("path_user_roles.user_role_id = ? and is_published = ? and name LIKE ?", user.user_role_id, true, "%#{name}%")
  end
  
  def self.similar_paths(path, user)
    unless path.nil?
      return Path.with_category(path.category_id, user, path.id, "id DESC")
    else
      return Path.with_category(user.company.categories.first.id, user)
    end
  end
  
  def self.suggested_paths(user, excluded_path_id = -1)
    paths = user.enrolled_paths
		enrolled_path_ids = []
		if paths.empty?
			return Path.with_category(user.company.categories.first.id, user)
		else
			category_counter = {}
			paths.each do |p|
				enrolled_path_ids << p.id
				category_counter[p.category_id] = category_counter[p.category_id].to_i + 1
			end
			logger.debug category_counter
			category_counter = category_counter.sort_by { |k,v| v }
			category_counter = category_counter
			logger.debug category_counter.to_a
			logger.debug category_counter.to_a[-1]
			return Path.with_category(category_counter.to_a[-1][0].to_i, user, enrolled_path_ids)
		end
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
		return total_remaining_tasks(user) <= 0
	end
	
	def total_remaining_tasks(user)
		remaining_tasks = 0
		sections.each {|s| remaining_tasks += s.remaining_tasks(user) }
		return remaining_tasks
	end
  
  def percent_complete(user)
    total_tasks = tasks.size
    total_remaining = total_remaining_tasks(user)
    return (((total_tasks - total_remaining.to_f) / total_tasks.to_f) * 100).to_i
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