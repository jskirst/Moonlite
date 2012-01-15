class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation, :earned_points, :spent_points, :image_url
	
	has_one :company_user
	has_one :company, :through => :company_user
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
	
	before_save :encrypt_password
	
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
		if company_user.nil?
			return false
		else
			return company_user.is_admin
		end
	end
	
	def award_points(task)
		self.update_attribute('earned_points', self.earned_points + task.points)
		enrollments.find_by_path_id(task.path_id).add_earned_points(task.points)
	end	
	
	def debit_points(points)
		self.update_attribute('spent_points', self.spent_points + points)
	end
	
	def available_points()
		available_points = self.earned_points
		spent_points = self.spent_points
		return available_points - spent_points
	end
	
	private
		def encrypt_password
			self.salt = make_salt if new_record?
			self.encrypted_password = encrypt(password)
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
end
