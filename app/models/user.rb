class User < ActiveRecord::Base
  attr_readonly :signup_token, :company_id
  attr_protected :admin, :login_at, :logout_at, :is_fake_user, :is_test_user, :earned_points, :spent_points, :user_role_id
  attr_accessor :password, :password_confirmation
  attr_accessible :name,
    :email, 
    :image_url,
    :password, 
    :password_confirmation, 
    :catch_phrase,
    :is_anonymous

  belongs_to :company
  belongs_to :user_role
  has_many :user_auths, :dependent => :destroy
  has_many :paths, :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :enrolled_paths, :through => :enrollments, :source => :path
  has_many :completed_tasks, :dependent => :destroy
  has_many :my_completed_tasks, :through => :completed_tasks, :source => :task
  has_many :user_personas, :dependent => :destroy
  has_many :achievements, :through => :user_achievements
  has_many :comments, :dependent => :destroy
  has_many :leaderboards, :dependent => :destroy
  has_many :user_events, :dependent => :destroy
  has_many :collaborations
  has_many :collaborating_paths, :through => :collaborations, :source => :path
  has_many :submitted_answers, :through => :completed_tasks
  has_many :votes
  has_many :user_transactions

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, length: { :within => 3..50 }
    
  validates :catch_phrase, length: { :maximum => 140 }

  validates :email,
    presence: true,
    format: { :with => email_regex },
    uniqueness: { :case_sensitive => false }

  validates :password,
    confirmation: true,
    length: { :within => 6..40 },
    on: :create
    
  validates :password,
    confirmation: true,
    length: { :within => 6..40 },
    on: :update,
    if: Proc.new { self.password.present? }
  
  before_save :encrypt_password
  before_save :set_tokens
  before_save :check_image_url
  before_save :check_user_type
  
  def self.find_with_omniauth(auth)
    user_auth = UserAuth.find_by_provider_and_uid(auth["provider"], auth["uid"])
    return user_auth.user if user_auth
    return nil
  end
  
  def self.create_anonymous_user(company)
    u = company.users.new
    u.is_anonymous = true
    u.password = (1..15).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    u.password_confirmation = u.password
    u.name = generate_username
    u.email = "#{u["name"]}@anonymous.metabright.com"
    u.user_role_id = company.user_role_id
    u.save
    return u
  end
  
  def self.create_with_omniauth(auth)
    user_auth = find_with_omniauth(auth)
    return user_auth.user if user_auth
    
    user_details = { 
        name: auth["info"]["name"], 
        email: auth["info"]["email"], 
        image_url: auth["info"]["image"],
        is_anonymous: false
    }
    user = User.find_by_email(auth["info"]["email"])
    if user
      user.update_attributes(user_details)
    else
      user = Company.find(1).users.new(user_details)
      user.password = (1..15).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
      user.password_confirmation = user.password
      user.save
    end
    
    user.user_auths.create!(provider: auth["provider"], uid: auth["uid"])
    return user
  end
  
  def merge_with_omniauth(auth)
    user = User.find_by_email(auth["info"]["email"])
    return false if user && user.id != self.id
    
    user_auth = user_auths.find_or_create_by_provider_and_uid(auth["provider"], auth["uid"])
    
    self.name = auth["info"]["name"]
    self.email = auth["info"]["email"]
    self.image_url = auth["info"]["image"]
    self.is_anonymous = false
    raise "User Auth save failed. " + self.errors.full_messages.join(". ") unless self.save
    return true
  end
  
  def must_register?
    self.email.include?("@anonymous.metabright.com")
  end
  
  def send_password_reset
    email_details = { :email => self.email, :token1 => self.signup_token }
    Mailer.reset(email_details).deliver
  end
  
  def profile_pic
    return self.image_url if self.image_url != nil
    return "/images/default_profile_pic.png"  if company.default_profile_picture_link.blank?
    return company.default_profile_picture_link
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
    enrollments.create!(path_id: path.id) unless enrollments.find_by_path_id(path.id)
  end
  
  def unenroll!(path)
    enrollments.find_by_path_id(path.id).destroy
  end
  
  def admin?
    return self.admin
  end
  
  def award_points(task, points)
    log_transaction(task.id, points)
    self.update_attribute('earned_points', self.earned_points + points)
    enrollments.find_by_path_id(task.section.path_id).add_earned_points(points)
  end
  
  def debit_points(points)
    self.update_attribute('spent_points', self.spent_points + points)
  end
  
  def available_points
    self.earned_points.to_i - self.spent_points
  end
  
  def most_recent_section_for_path(path)
    last_task = completed_tasks.includes(:path).where(["paths.id = ?", path.id]).first(:order => "completed_tasks.updated_at DESC")
    return path.sections.first(:order => "position ASC") if last_task.nil?
    return last_task.section
  end
  
  def completed?(task)
    completed_tasks.find_by_task_id(task.id)
  end
  
  def path_started?(path)
    return true unless my_completed_tasks.includes(:path).where(["paths.id = ?", path.id]).empty?
  end
  
  def section_started?(section)
    return true unless my_completed_tasks.where(["section_id = ?", section.id]).empty?
  end
  
  def usage(stat)
    return enrolled_paths.count if stat == "enrolled_paths"
    return completed_tasks.where("status_id = ?", 0).count if stat == "incorrect_answers"
    return completed_tasks.where("status_id = ?", 1).count if stat == "correct_answers"
    return completed_tasks.last.created_at unless completed_tasks.last.nil? if stat == "last_action"
    return enrolled_paths.to_a.count { |p| p.completed?(self) } if stat == "completed_paths"
  end
  
  private  
    def check_image_url
      unless self.image_url.nil?
        self.image_url = nil if self.image_url.length < 9
      end
    end
    
    def check_user_type
      self.is_fake_user = true if self.email.include?("@demo.moonlite.com")
      #self.is_anonymous = true if !self.email.include?("anonymous")
      self.is_test_user = true if self.name.include?("test_user")
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
      self.signup_token = random_alphanumeric if self.signup_token == nil
    end
    
    def random_alphanumeric(size=15)
      (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    end
    
    def log_transaction(task_id, points)
      user_transactions.create!(owner_id: task_id, owner_type: "Task", amount: points, status: 1)
    end
    
    def self.generate_random_username()
      num = 11 + rand(1000)
      [USERNAME_ADJS.sample.capitalize,USERNAME_NOUNS.sample.capitalize,num].join
    end
    
    def self.generate_username
      loop do
        username = generate_random_username()
        return username unless User.find_by_name(username)
      end
    end
end