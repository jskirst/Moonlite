require 'open-uri'

class User < ActiveRecord::Base
  attr_readonly :signup_token, :company_id
  attr_protected :admin, :login_at, :logout_at, :is_fake_user, :is_test_user, :earned_points, :spent_points, :user_role_id, :is_locked
  attr_accessor :password, :password_confirmation
  attr_accessible :name,
    :email, 
    :image_url,
    :password, 
    :password_confirmation, 
    :username,
    :description,
    :title,
    :company_name,
    :education,
    :link,
    :location,
    :viewed_help

  belongs_to :company
  belongs_to :user_role
  has_many :user_auths, dependent: :destroy
  has_many :paths
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_paths, through: :enrollments, source: :path
  has_many :completed_tasks, dependent: :destroy
  has_many :my_completed_tasks, through: :completed_tasks, source: :task
  has_many :user_personas, dependent: :destroy
  has_many :personas, through: :user_personas
  has_many :achievements, through: :user_achievements
  has_many :comments, dependent: :destroy
  has_many :user_events, dependent: :destroy
  has_many :collaborations
  has_many :collaborating_paths, through: :collaborations, source: :path
  has_many :submitted_answers, through: :completed_tasks
  has_many :votes
  has_many :user_transactions
  has_many :task_issues
  
  validates :name, length: { within: 3..100 }
  validates :username, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]+\z/, message: "Only letters allowed" }
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, length: { within: 6..40 }, on: :create
  validates :password, confirmation: true, length: { within: 6..40 }, on: :update, if: Proc.new { self.password.present? }
  
  before_save :encrypt_password
  before_save :set_tokens
  before_save :set_default_user_role
  before_validation :grant_username
  
  def to_s
    return self.name
  end
  
  def self.find_with_omniauth(auth)
    user_auth = UserAuth.find_by_provider_and_uid(auth["provider"], auth["uid"])
    return user_auth.user if user_auth
    return nil
  end
  
  def self.create_with_omniauth(auth)
    user_auth = find_with_omniauth(auth)
    return user_auth.user if user_auth
    
    user_details = { 
        name: auth["info"]["name"], 
        email: auth["info"]["email"],
    }
    
    begin
      info = auth[:extra][:raw_info]
      if auth[:provider] == "facebook"
        user_details[:image_url] = auth["info"]["image"].gsub("type=small", "type=large").gsub("type=square", "type=large")
        user_details[:description] = info[:bio]
        user_details[:link] = info[:link]
        user_details[:location] = info[:location][:name] if info[:location]
        user_details[:company_name] = info[:work][-1][:employer][:name] if info[:work][-1]
        user_details[:education] = info[:education][-1][:school][:name] if info[:education][-1]
      elsif auth[:provider] == "google_oauth2"
        user_details[:image_url] = auth["info"]["image"]
        url = URI.parse("https://www.googleapis.com/plus/v1/people/me?access_token=#{auth[:credentials][:token]}")
        info = JSON.parse(open(url).read)
        user_details[:link] = info["url"]
        user_details[:description] = info["tagline"] || info["aboutMe"]
        if info["organizations"]
          info["organizations"].each { |org| user_details[:education] = [org["name"], org["title"]].compact.join(",") if org["type"] == "school" }
          info["organizations"].each { |org| user_details[:company_name] = org["name"] if org["type"] == "work" }
          info["organizations"].each { |org| user_details[:title] = org["title"] if org["type"] == "work" }
        end
        if info["placesLived"]
          info["placesLived"].each { |place| user_details[:location] = place["value"] if place["primary"] == true }
        end
      else
        raise "Cannot recognize provider."
      end
    rescue
      logger.debug $!.to_s
    end
    
    user = User.find_by_email(auth["info"]["email"])
    if user
      user.update_attributes(user_details)
    else
      user = Company.first.users.new(user_details)
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
    raise "User Auth save failed. " + self.errors.full_messages.join(". ") unless self.save
    return true
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
  
  def profile_complete?
    !self.description.nil?
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
    return enrollments.find_by_path_id(path.id)
  end
  
  def enroll!(obj)
    if obj.is_a? Path
      enrollments.create!(path_id: obj.id) unless enrollments.find_by_path_id(obj.id)
    elsif obj.is_a? Persona
      user_personas.create!(persona_id: obj.id) unless user_personas.find_by_persona_id(obj.id)
    else
      raise "Invalid object to enroll."
    end
  end
  
  def unenroll!(path)
    enrollments.find_by_path_id(path.id).destroy
  end
  
  def award_points(task, points)
    if points.to_i > 0
      log_transaction(task.id, points)
      self.update_attribute('earned_points', self.earned_points + points)
      enrollments.find_by_path_id(task.section.path_id).add_earned_points(points)
    end
  end
  
  def retract_points(task, points)
    log_transaction(task.id, points * -1)
    self.update_attribute('earned_points', self.earned_points - points)
    enrollment = enrollments.find_by_path_id(task.section.path_id)
    enrollment.update_attribute(:total_points, enrollment.total_points - points)
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
  
  def level(path)
    return enrollments.find_by_path_id(path).level
  end
  
  def points(path)
    return enrollments.find_by_path_id(path).total_points
  end
  
  def grant_username
    if self.username.blank?
      new_username = self.name.downcase.gsub(/[^a-z]/,'')
      new_combined_username = new_username
      username_count = User.where(username: new_combined_username).size
      while User.where(username: new_combined_username).size > 0
        username_count += 1
        new_combined_username = "#{new_username}#{username_count}"
      end
      self.username = new_combined_username
    end
  end
  
  def get_viewed_help
    return [] if self.viewed_help.blank?
    return self.viewed_help.split(",")
  end
  
  def set_viewed_help(help_id)
    raise "FATAL: Illegal viewed_help" if help_id && help_id.index(/[^a-z_,]/)
    
    if self.viewed_help.blank?
      self.viewed_help = help_id
    else
      help = self.viewed_help.split(",")
      help.push(help_id)
      self.viewed_help = help.join(",")
    end
    self.save!
  end
  
  private
    def set_default_user_role
      if self.user_role_id.nil?
        self.user_role_id = self.company.user_role_id
      end
    end
    
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
      self.signup_token = random_alphanumeric if self.signup_token == nil
    end
    
    def random_alphanumeric(size=15)
      (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
    end
    
    def log_transaction(task_id, points)
      user_transactions.create!(owner_id: task_id, owner_type: "Task", amount: points, status: 1)
    end
end