class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation
	
	has_one :company_user
	has_one :company, :through => :company_user
	has_many :paths, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	has_many :enrolled_paths, :through => :enrollments, :source => :path
	has_many :completed_tasks, :dependent => :destroy
	has_many :my_completed_tasks, :through => :completed_tasks, :source => :task
	
	
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
	
	def total_earned_points(path = nil)
		total_earned_points = 0
		cp = completed_tasks.find_all_by_status_id(1)
		cp.each do |t|
			if path.nil? || t.task.path_id == path.id
				total_earned_points += t.task.points
			end
		end
		return total_earned_points
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
