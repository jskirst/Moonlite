class User < ActiveRecord::Base
	attr_protected :admin, :user_roll
	attr_accessor :password, :password_confirmation
	attr_accessible :name, :email, :earned_points, :spent_points, :image_url, :signup_token, :company_admin, :password, :password_confirmation
	
	belongs_to :company
	belongs_to :user_roll
	has_many :paths, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	has_many :enrolled_paths, :through => :enrollments, :source => :path
	has_many :completed_tasks, :dependent => :destroy
	has_many :my_completed_tasks, :through => :completed_tasks, :source => :task
	has_many :user_achievements, :dependent => :destroy
  has_many :comments, :dependent => :destroy
	has_many :leaderboards, :dependent => :destroy
	has_many :user_events, :dependent => :destroy
	
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :name, 		
		:presence 	=> true,
		:length		=> { :maximum => 50 }
	
	validates :email,		
		:presence 	=> true,
		:format		=> { :with => email_regex },
		:uniqueness => { :case_sensitive => false }
	
	validates :password,
		:presence	=> true,
		:confirmation => true,
		:length		=> { :within => 6..40 },
		:on => :create
		
	validates :password,
		:confirmation => true,
		:length		=> { :within => 6..40 },
		:on => :update,
		:if => :validate_password?
	
	before_save :encrypt_password
	before_save :set_tokens
  before_save :check_image_url
	
	def validate_password?
		return self.password.present?
	end
	
	def send_invitation_email
		email_details = { :email => self.email, :token1 => self.signup_token }
		Mailer.welcome(email_details).deliver
	end
	
	def send_password_reset
		email_details = { :email => self.email, :token1 => self.signup_token }
		Mailer.reset(email_details).deliver
	end
	
	def profile_pic
		if self.image_url != nil
			return self.image_url
		else
			if company.default_profile_picture_link.blank?
				return "/images/default_profile_pic.jpg"
			else
				return company.default_profile_picture_link
			end
		end
	end
	
	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end
	
	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end
	
	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		(user && user.salt == cookie_salt) ? user : nil
	end
	
	def enrolled?(path)
		return true unless enrollments.find_by_path_id(path.id).nil?
	end
	
	def enroll!(path)
		if enrollments.find_by_path_id(path.id).nil?
			enrollments.create!(:path_id => path.id)
		end
	end
	
	def unenroll!(path)
		enrollments.find_by_path_id(path.id).destroy
	end

	def completed?(task)
		completed_tasks.find_by_task_id(task.id)
	end
	
	def admin?
		return self.admin
	end
	
	def company_admin?
		return company_admin
	end
  
  def award_points_and_achievements(task, points)
    award_points(task, points)
    return award_achievements(task)
  end
  
  def award_points(task, points)
    log_transaction(task.id, points)
		self.update_attribute('earned_points', self.earned_points + points)
		enrollments.find_by_path_id(task.section.path_id).add_earned_points(points)
	end
	
	def award_achievements(task)
		potential_achievements = task.path.achievements
		potential_achievements.each do |pa|
      unless pa.criteria.nil?
				task_ids = pa.criteria.split(",")
        cps = completed_tasks.find_all_by_task_id(task_ids, :conditions => ["status_id = ?", 1])
        if cps.size == task_ids.size && !self.has_achievement?(pa.id)
					user_achievements.create!(:achievement_id => pa.id)
					update_attribute('earned_points', self.earned_points + pa.points)
          return pa
				end
			end
		end
    return false
	end
  
  def has_achievement?(achievement_id)
    achievement = self.user_achievements.find_by_achievement_id(achievement_id)
    return achievement.nil? ? false : true
  end
	
	def debit_points(points)
		self.update_attribute('spent_points', self.spent_points + points)
	end
	
	def available_points()
		available_points = self.earned_points
		spent_points = self.spent_points
		return available_points - spent_points
	end
	
	def most_recent_section_for_path(path)
		last_task = completed_tasks.includes(:path).where(["paths.id = ?", path.id]).first(:order => "completed_tasks.updated_at DESC")
    return path.sections.first if last_task.nil?
		return last_task.section
  end
	
	def set_company_admin(val)
		current_val = self.company_admin
		if !current_val && val == true
			self.toggle!(:company_admin)
		elsif !val && current_val == true
			self.toggle!(:company_admin)
		end
	end
  
  def path_started?(path)
    return true unless my_completed_tasks.includes(:path).where(["paths.id = ?", path.id]).empty?
  end
  
  def section_started?(section)
    return true unless my_completed_tasks.where(["section_id = ?", section.id]).empty?
  end
	
	private
    def check_image_url
      unless self.image_url.nil?
        self.image_url = nil if self.image_url.length < 9
      end
    end
  
		def encrypt_password
			if self.password.present?
				self.salt = make_salt
				self.encrypted_password = encrypt(password)
			end
		end
		
		def encrypt(string)
			secure_hash("#{salt}--#{string}")
		end
		
		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end
		
		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
		
		def set_tokens
			if(self.signup_token == nil)
				self.signup_token = random_alphanumeric
			end
		end
		
		def random_alphanumeric(size=15)
			(1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
		end
    
    def log_transaction(task_id, points)
      UserTransaction.create!({:user_id => self.id,
        :task_id => task_id, 
        :amount => points,
        :status => 1})
    end
end
