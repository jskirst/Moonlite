require 'open-uri'
class User < ActiveRecord::Base
  MAX_DAILY_EMAILS = 8
  
  attr_readonly :signup_token, :company_id
  attr_protected :admin, 
    :login_at, :logout_at, :locked_at,
    :is_fake_user, :is_test_user, :user_role_id,
    :earned_points, :spent_points,
    :last_email_sent_at,:emails_today
  attr_accessor :password, :password_confirmation, :guest_user
  attr_accessible :name, :email, :image_url, :username,
    :password,:password_confirmation, 
    :description, :title, :company_name, :education, :link, :location,
    :viewed_help, :guest_user,
    :city, :state, :country, 
    :seen_opportunities, :wants_full_time, :wants_part_time, :wants_internship
    

  belongs_to  :company
  belongs_to  :user_role
  has_one     :notification_settings
  has_many    :user_auths, dependent: :destroy
  has_many    :paths
  has_many    :enrollments, dependent: :destroy
  has_many    :enrolled_paths, through: :enrollments, source: :path
  has_many    :completed_tasks, dependent: :destroy
  has_many    :my_completed_tasks, through: :completed_tasks, source: :task
  has_many    :user_personas, dependent: :destroy
  has_many    :personas, through: :user_personas
  has_many    :achievements, through: :user_achievements
  has_many    :comments, dependent: :destroy
  has_many    :user_events, dependent: :destroy
  has_many    :collaborations
  has_many    :collaborating_paths, through: :collaborations, source: :path
  has_many    :submitted_answers, through: :completed_tasks
  has_many    :ideas, foreign_key: "creator_id"
  has_many    :votes, conditions: { owner_type: "SubmittedAnswer" }
  has_many    :idea_votes, class_name: "Vote", conditions: { owner_type: "Idea" }
  has_many    :user_transactions
  has_many    :task_issues
  has_many    :subscriptions, foreign_key: "follower_id"
  has_many    :subscribers, class_name: "Subscription", foreign_key: "followed_id"
  has_many    :followers, through: :subscribers
  has_many    :followed_users, through: :subscriptions, source: :followed
  has_many    :created_tasks, class_name: "Task", foreign_key: :creator_id
  has_many    :visits
  has_many    :group_users
  has_many    :groups, through: :group_users

  
  validates :name, length: { within: 3..100 }
  validates :username, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]+\z/, message: "Only letters allowed" }
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, length: { within: 6..40 }, on: :create
  validates :password, confirmation: true, length: { within: 6..40 }, on: :update, if: Proc.new { self.password.present? }
  
  before_save do
    if self.password.present?
      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end
    self.user_role_id = self.company.user_role_id if self.user_role_id.nil?
  end
  
  before_create do
    self.signup_token = SecureRandom::hex(16)
    self.login_at = Time.now
  end
  
  after_create do
    NotificationSettings.create!(user_id: self.id)
  end
  
  def to_s() self.name end
    
  def locked?() locked_at.nil? ? false : true end
  def guest_user?() email.include?("@metabright") end
    
  def professional_enabled?() wants_internship or wants_full_time or wants_part_time end
  
  def self.create_with_nothing(email = nil)
    user = Company.first.users.new
    user.name = grant_anon_username
    user.email = email || "#{user.name}@metabright.com"
    user.grant_username
    user.password = SecureRandom::hex(16)
    user.password_confirmation = user.password
    user.save!
    return user
  end
  
  def self.find_with_omniauth(auth)
    user_auth = UserAuth.find_by_provider_and_uid(auth["provider"], auth["uid"])
    return user_auth.user if user_auth
    return nil
  end
  
  def merge_existing_with_omniauth(auth)
    User.create_with_omniauth(auth, self)
  end
  
  def self.create_with_omniauth(auth, user = nil)
    user_from_auth = User.find_with_omniauth(auth)
    return user_from_auth if user_from_auth
    
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
    
    user = User.find_by_email(auth["info"]["email"]) unless user
    if user
      user.update_attributes(user_details)
      user.grant_username(force_rename: true)
    else
      user = Company.first.users.new(user_details)
      user.password = SecureRandom::hex(16)
      user.password_confirmation = user.password
      user.grant_username
    end
    user.save!
    
    user.user_auths.create!(provider: auth["provider"], uid: auth["uid"])
    return user
  end
  
  def merge_with_omniauth(auth)
    unless guest_user?
      user = User.find_by_email(auth["info"]["email"])
      return false if user && user.id != self.id
    end
    
    user_auth = user_auths.find_or_create_by_provider_and_uid(auth["provider"], auth["uid"])
    
    self.name = auth["info"]["name"]
    self.email = auth["info"]["email"]
    self.image_url = auth["info"]["image"]
    raise "User Auth save failed. " + self.errors.full_messages.join(". ") unless self.save
    return true
  end
  
  def self.auth(redirect_url)
    FbGraph::Auth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"], :redirect_uri =>  redirect_url)
  end
  
  def send_password_reset
    email_details = { :email => self.email, :token1 => self.signup_token }
    Mailer.reset(email_details).deliver
  end
  
  def self.picture(image_url)
    return image_url unless image_url.blank?
    return ICON_DEFAULT_PROFILE
  end
  def picture() User.picture(self.image_url) end
  
  def profile_complete?() !self.description.nil? end
  def has_password?(submitted_password) encrypted_password == encrypt(submitted_password) end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def enrolled?(path) enrollments.find_by_path_id(path.id) end
  def enroll!(obj)
    if obj.is_a? Path
      enrollments.create!(path_id: obj.id) unless enrollments.find_by_path_id(obj.id)
    elsif obj.is_a? Persona
      user_personas.create!(persona_id: obj.id) unless user_personas.find_by_persona_id(obj.id)
    else
      raise "Invalid object to enroll."
    end
  end
  def unenroll!(path) enrollments.find_by_path_id(path.id).destroy end
  
  def award_points(obj, points)
    if points.to_i > 0
      if obj.is_a? CompletedTask
        enrollment = enrollments.find_by_path_id(obj.section.path_id)
      elsif obj.is_a? Vote
        enrollment = enrollments.find_by_path_id(obj.owner.task.section.path_id)
      elsif obj.is_a? Task
        enrollment = enrollments.find_by_path_id(obj.section.path_id)
      else
        raise "unknown object"
      end
      raise "Enrollment nil" unless enrollment
      log_transaction(obj, points)
      self.update_attribute('earned_points', self.earned_points + points)
      enrollment.add_earned_points(points)
    end
  end
  def retract_points(obj, points)
    raise "Subtracting 0 points" if points.to_i == 0
    if obj.is_a? CompletedTask
      enrollment = enrollments.find_by_path_id(obj.section.path_id)
    elsif obj.is_a? Vote
      enrollment = enrollments.find_by_path_id(obj.owner.task.section.path_id)
    elsif obj.is_a? Task
      enrollment = enrollments.find_by_path_id(obj.section.path_id)
    else
      raise "unknown object"
    end
    raise "Enrollment nil" unless enrollment
    log_transaction(obj, points * -1)
    self.update_attribute(:earned_points, self.earned_points - points)
    enrollment.remove_earned_points(points)
  end
  
  def debit_points(points) self.update_attribute('spent_points', self.spent_points + points) end
  def available_points() self.earned_points.to_i - self.spent_points end
  
  def most_recent_section_for_path(path)
    last_task = completed_tasks.includes(:path).where(["paths.id = ?", path.id]).first(:order => "completed_tasks.updated_at DESC")
    return path.sections.first(:order => "position ASC") if last_task.nil?
    return last_task.section
  end
  
  def path_started?(path) !my_completed_tasks.includes(:path).where(["paths.id = ?", path.id]).empty? end
  def section_started?(section) !my_completed_tasks.where(["section_id = ?", section.id]).empty? end
  def completed?(task) completed_tasks.find_by_task_id(task.id) end
  def level(path) enrollments.find_by_path_id(path).level end
  def points(path) enrollments.find_by_path_id(path).total_points end
  
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
  
  def can_email?(type = nil)
    if locked?
      puts "User is locked"
      return false
    end
    
    if (last_email_sent_at && last_email_sent_at.to_date.today?) && (emails_today && emails_today >= MAX_DAILY_EMAILS)
      puts "Emailed too much today"
      return false
    end
    
    settings = notification_settings
    return false if settings.inactive
    return false if type == :interaction && !settings.interaction
    return false if type == :powers && !settings.powers
    return false if type == :weekly && !settings.weekly
    return true
  end
  
  def log_email
    if last_email_sent_at && last_email_sent_at.to_date.today?
      self.emails_today += 1
    else
      self.emails_today = 1
    end
    
    self.last_email_sent_at = DateTime.now
    self.save!
    return self
  end
  
  def vote_list
    votes.to_a.collect {|v| v.owner_id }
  end
  
  def reputation_badge
    if earned_points < 2000
      return nil
    elsif earned_points < 4000
      return [ICON_BADGE_1, "Earned more than 2,000 MetaBright points"]
    elsif earned_points < 6000
      return [ICON_BADGE_2, "Earned more than 4,000 MetaBright points"]
    elsif earned_points < 10000
      return [ICON_BADGE_3, "Earned more than 6,000 MetaBright points"]
    elsif earned_points < 15000
      return [ICON_BADGE_4, "Earned more than 10,000 MetaBright points"]
    elsif earned_points < 20000
      return [ICON_BADGE_5, "Earned more than 15,000 MetaBright points"]
    elsif earned_points < 25000
      return [ICON_BADGE_6, "Earned more than 20,000 MetaBright points"]
    elsif earned_points < 35000
      return [ICON_BADGE_7, "Earned more than 25,000 MetaBright points"]
    elsif earned_points < 40000
      return [ICON_BADGE_8, "Earned more than 35,000 MetaBright points"]
    elsif earned_points > 40000
      return [ICON_BADGE_9, "Earned more than 40,000 MetaBright points"]
    end
  end
  
  def grant_username(options = {})
    if username.blank? or options[:force_rename]
      self.username = generate_username
    end
  end

  def generate_username
    return SecureRandom::hex(6) if name.nil?
    
    new_username = name.downcase.gsub(/[^a-z0-9]/i,'')
    new_combined_username = new_username
    username_count = User.where(username: new_combined_username).size
    while User.where(username: new_combined_username).size > 0
      username_count += 1
      new_combined_username = "#{new_username}#{username_count}"
    end
    
    new_combined_username = SecureRandom::hex(6) if new_combined_username.length >= 255
    return new_combined_username
  end
  
  def self.grant_anon_username() USERNAME_ADJS.shuffle.first.capitalize + USERNAME_NOUNS.shuffle.first.capitalize + rand(500).to_s end
  
  private  
  def check_image_url() self.image_url = nil if self.image_url && self.image_url.length < 9 end
  
  def encrypt(string) secure_hash("#{salt}--#{string}") end
  def make_salt() secure_hash("#{Time.now.utc}--#{password}") end
  def secure_hash(string) Digest::SHA2.hexdigest(string) end
  
  def log_transaction(obj, points)
    user_transactions.create!(owner_id: obj.id, owner_type: obj.class.to_s, amount: points, status: 1)
  end
end