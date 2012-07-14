class User < ActiveRecord::Base
  attr_readonly :signup_token
  attr_protected :admin, :login_at, :logout_at, :is_fake_user, :is_test_user, :earned_points, :spent_points, :user_role_id, :company_admin
  attr_accessor :password, :password_confirmation
  attr_accessible :company_id, 
    :name,
    :email, 
    :image_url,
    :password, 
    :password_confirmation, 
    :catch_phrase, 
    :provider, 
    :uid,
    :is_anonymous

  belongs_to :company
  belongs_to :user_role
  has_many :user_auths, :dependent => :destroy
  has_many :paths, :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :enrolled_paths, :through => :enrollments, :source => :path
  has_many :completed_tasks, :dependent => :destroy
  has_many :my_completed_tasks, :through => :completed_tasks, :source => :task
  has_many :user_achievements, :dependent => :destroy
  has_many :achievements, :through => :user_achievements
  has_many :comments, :dependent => :destroy
  has_many :leaderboards, :dependent => :destroy
  has_many :user_events, :dependent => :destroy
  has_many :collaborations
  has_many :collaborating_paths, :through => :collaborations, :source => :path
  has_many :submitted_answers, :through => :completed_tasks
  has_many :votes

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name,     
    :presence   => true,
    :length    => { :within => 3..50 }
    
  validates :catch_phrase,
    :length    => { :maximum => 140 }

  validates :email,    
    :presence   => true,
    :format    => { :with => email_regex },
    :uniqueness => { :case_sensitive => false }

  validates :password,
    :presence  => true,
    :confirmation => true,
    :length    => { :within => 6..40 },
    :on => :create
    
  validates :password,
    :confirmation => true,
    :length    => { :within => 6..40 },
    :on => :update,
    :if => :validate_password?
  
  before_save :encrypt_password
  before_save :set_tokens
  before_save :check_image_url
  before_save :check_user_type
  
  def self.find_with_omniauth(auth)
    user_auth = UserAuth.find_by_provider_and_uid(auth["provider"], auth["uid"])
    return user_auth.user if user_auth
    return nil
  end
  
  def self.create_anonymous_user(company, details = nil)
    u = Hash.new if details.nil?
    u["password"] ||= (1..15).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    u["password_confirmation"] = u["password"]
    u["name"] ||= generate_username
    u["email"] ||= "#{u["name"]}@anonymous.metabright.com"
    u["image_url"] ||= nil
    u["is_anonymous"] ||= true
    u["company_id"] ||= company.id
    
    user = company.users.create!(u)
    user.user_role_id = company.user_role_id
    user.save
    return user
  end
  
  def self.create_with_omniauth(auth)
    user_auth = UserAuth.find_by_provider_and_uid(auth["provider"], auth["uid"])
    return user_auth.user if user_auth
    
    user_details = {:name => auth["info"]["name"], 
        :email => auth["info"]["email"], 
        :image_url => auth["info"]["image"],
        :is_anonymous => false}
    if user
      user = User.find_by_email(auth["info"]["email"])
      user.update_attributes(user_details)
    else
      user = create_anonymous_user(Company.find(1), user_details)
    end
    
    user.user_auths.create!(:provider => auth["provider"], :uid => auth["uid"])
    return user
  end
  
  def merge_with_omniauth(auth)
    user_auth = user_auths.find_by_provider_and_uid(auth["provider"], auth["uid"])
    user = User.find_by_email(auth["info"]["email"])
    if user && user.id != self.id
      return false
    end
    
    if user_auth.nil?
      user_auth = user_auths.create!(:provider => auth["provider"], :uid => auth["uid"])
    end
    
    self.name = auth["info"]["name"]
    self.email = auth["info"]["email"]
    self.image_url = auth["info"]["image"]
    self.is_anonymous = false
    raise "User Auth save failed. " + self.errors.full_messages.join(". ") unless self.save
    return true
  end
  
  def self.generate_username
    loop do
      username = generate_random_username()
      return username unless User.find_by_name(username)
    end
  end
  
  def must_register?
    return self.email.include?("@anonymous.metabright.com")
  end
  
  def validate_password?
    return self.password.present?
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
    # potential_achievements = task.path.achievements
    # if potential_achievements
      # potential_achievements.each do |pa|
        # unless pa.criteria.nil?
          # task_ids = pa.criteria.split(",")
          # cps = completed_tasks.find_all_by_task_id(task_ids, :conditions => ["status_id = ?", 1])
          # if cps.size == task_ids.size && !self.has_achievement?(pa.id)
            # user_achievements.create!(:achievement_id => pa.id)
            # update_attribute('earned_points', self.earned_points + pa.points)
            # return pa
          # end
        # end
      # end
    # end
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
    return path.sections.first(:order => "position ASC") if last_task.nil?
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
    if stat == "enrolled_paths"
      return enrolled_paths.count
    elsif stat == "completed_paths"
      counter = 0
      enrolled_paths.each do |p|
        counter += 1 if p.completed?(self)
      end
      return counter
    elsif stat == "incorrect_answers"
      return completed_tasks.where("status_id = ?", 0).count
    elsif stat == "correct_answers"
      return completed_tasks.where("status_id = ?", 1).count
    elsif stat == "last_action"
      return completed_tasks.last.created_at unless completed_tasks.last.nil?
    end
  end
  
  private  
    def check_image_url
      unless self.image_url.nil?
        self.image_url = nil if self.image_url.length < 9
      end
    end
    
    def check_user_type
      if self.email.include?("@demo.moonlite.com")
        self.is_fake_user = true
      elsif !self.email.include?("anonymous")
        #self.is_anonymous = true
      elsif self.name.include?("test_user")
        self.is_test_user = true
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
    
    def self.generate_random_username()
      num = 11 + rand(1000)
      return [adjs.sample.capitalize,nouns.sample.capitalize,num].join
    end
    
    def self.adjs()
      return %w[aged ancient autumn billowing bitter black blue bold broken cold cool crimson damp dark dawn delicate divine dry empty falling floral fragrant frosty green hidden holy icy late lingering little lively long misty morning muddy nameless old patient polished proud purple quiet red restless rough shy silent small snowy solitary sparkling spring still summer throbbing twilight wandering weathered white wild winter wispy withered young]
    end
  
    def self.nouns()
      return %w[bird breeze brook bush butterfly cherry cloud darkness dawn dew dream dust feather field fire firefly flower fog forest frog frost glade glitter grass haze hill lake leaf meadow moon morning mountain night paper pine pond rain resonance river sea shadow shape silence sky smoke snow snowflake sound star sun sun sunset surf thunder tree violet voice water water waterfall wave wildflower wind wood]
    end
end
