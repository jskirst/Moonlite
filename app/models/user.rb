class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation, :earned_points, :spent_points, :image_url, :signup_token, :company_admin
	
	belongs_to :company
	has_many :paths, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	has_many :enrolled_paths, :through => :enrollments, :source => :path
	has_many :completed_tasks, :dependent => :destroy
	has_many :my_completed_tasks, :through => :completed_tasks, :source => :task
	has_many :user_achievements, :dependent => :destroy
	
	
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
		:length		=> { :within => 6..40 }
	
	before_save :encrypt_password, :only => [:create]
	before_save :set_tokens
	
	def send_invitation_email
		email_details = { :email => self.email, :token1 => self.signup_token }
		Mailer.welcome(email_details).deliver
	end
	
	def profile_pic
		if self.image_url != nil
			return self.image_url
		else
			return "/images/default_profile_pic.jpg"
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
		enrollments.find_by_path_id(path.id)
	end
	
	def enroll!(path)
		enrollments.create!(:path_id => path.id)
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
	
	def award_points(task)
		self.update_attribute('earned_points', self.earned_points + task.points)
		enrollments.find_by_path_id(task.section.path_id).add_earned_points(task.points)
	end
  
  def has_achievement?(achievement_id)
    achievement = self.user_achievements.find_by_achievement_id(achievement_id)
    return achievement.nil? ? false : true
  end
	
	def award_achievements(completed_task)
		section = completed_task.task.section
		path = section.path
		potential_achievements = path.achievements
		potential_achievements.each do |pa|
      unless pa.criteria.nil?
				completed_all = true
				task_ids = pa.criteria.split(",")
				task_ids.each do |id|
					t = Task.find_by_id(id)
					if t.nil? || !self.completed?(t)
						completed_all = false
						break
					end
				end
				if completed_all && !self.has_achievement?(pa.id)
					self.user_achievements.create!(:achievement_id => pa.id)
					self.update_attribute('earned_points', self.earned_points + pa.points)
          return pa
				end
			end
		end
    return false
	end
	
	def debit_points(points)
		self.update_attribute('spent_points', self.spent_points + points)
	end
	
	def available_points()
		available_points = self.earned_points
		spent_points = self.spent_points
		return available_points - spent_points
	end
	
	def most_recent_section(path)
		cps = self.completed_tasks.all(:order => "completed_tasks.updated_at DESC")
		cps.each do |cp|
			if cp.path.id == path.id
				return cp.task.section
			end
		end
		return nil
	end
	
	def set_company_admin(val)
		current_val = self.company_admin
		if !current_val && val == true
			self.toggle!(:company_admin)
		elsif !val && current_val == true
			self.toggle!(:company_admin)
		end
	end
	
	private
		def encrypt_password
			if new_record?
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
end
