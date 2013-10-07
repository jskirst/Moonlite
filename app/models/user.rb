require 'open-uri'
class User < ActiveRecord::Base
  MAX_DAILY_EMAILS = 5
  
  GUEST_WHITELIST = ["jskirst@metabright.com", "nsdub@metabright.com", "team@metabright.com", 
    "founders@metabright.com", "support@metabright.com", "admin@metabright.com"]
  
  attr_readonly :signup_token
  attr_protected :admin, 
    :login_at, :logout_at, :locked_at,
    :is_fake_user, :is_test_user, :user_role_id,
    :earned_points, :spent_points,
    :last_email_sent_at,:emails_today
  attr_accessor :password, :password_confirmation, :guest_user, :group_id
  attr_accessible :name, :email, :image_url, :username,
    :password,:password_confirmation, 
    :description, :title, :company_name, :education, :link, :location, :guest_user,
    :city, :state, :country, 
    :seen_opportunities, :wants_full_time, :wants_part_time, :wants_internship
    
  belongs_to  :user_role
  has_one     :notification_settings
  has_one     :custom_style, as: :owner
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
  has_many    :votes, -> { where owner_type: "SubmittedAnswer" }
  has_many    :idea_votes, -> { where owner_type: "Idea" }, class_name: "Vote"
  has_many    :user_transactions
  has_many    :task_issues
  has_many    :subscriptions, foreign_key: "follower_id"
  has_many    :subscribers, class_name: "Subscription", foreign_key: "followed_id"
  has_many    :followers, through: :subscribers
  has_many    :followed_users, through: :subscriptions, source: :followed
  has_many    :created_tasks, class_name: "Task", foreign_key: :creator_id
  has_many    :visits
  has_many    :group_users, dependent: :destroy
  has_many    :groups, through: :group_users
  has_many    :sent_emails
  has_many    :authored_evaluations, class_name: "Evaluation"
  has_many    :evaluation_enrollments, dependent: :destroy
  has_many    :evaluations, through: :evaluation_enrollments
  
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
    
    if self.name_changed?
      grant_username(force_rename: true)
    end
  end
  
  before_create do
    self.signup_token = SecureRandom::hex(16)
    self.login_at = Time.now
    grant_username if username.blank?
  end
  
  after_create do
    NotificationSettings.create!(user_id: self.id)
    if group_id
      GroupUser.create!(user_id: self.id, group_id: self.group_id)
    end
  end
  
  after_save :flush_cache
  before_destroy do
    if Rails.env != "development" and self.enable_administration
      raise "Cannot delete an admin account."
    else
      return true
    end
  end
  before_destroy :flush_cache
  
  def to_s() self.name end
    
  def locked?() locked_at.nil? ? false : true end
  def content_creation_enabled?() not self.content_creation_enabled_at.nil? end
  def guest_user?() email.include?("@metabright") and not GUEST_WHITELIST.include?(email) end
    
  def professional_enabled?() wants_internship or wants_full_time or wants_part_time end
  
  def self.create_with_nothing(details = nil)
    details = {} unless details
    group = Group.find(details["group_id"]) unless details["group_id"].blank?
    user = User.new
    user.name = details["name"] || grant_anon_username
    user.email = details["email"] || "#{user.name}@metabright.com"
    user.grant_username
    user.password = details["password"] || SecureRandom::hex(16)
    user.password_confirmation = user.password
    user.group_id = group.id if group
    user.save
    return user
  end
  
  def self.find_with_omniauth(auth)
    return User.joins(:user_auths).where("user_auths.provider = ? and user_auths.uid = ?", auth["provider"], auth["uid"]).first
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
      
      elsif auth[:provider] == "linkedin"
      
        user_details[:description] = auth[:info][:description]
        user_details[:link] = info[:publicProfileUrl]
        user_details[:location] = auth[:info][:location][:name] if info[:location]
        user_details[:image_url] = info[:pictureUrl] 
      
      elsif auth[:provider] == "github"
      
        user_details[:description] = info[:bio]
        user_details[:link] = auth[:info][:urls].first if auth[:info][:urls]
        user_details[:location] = info[:location]
        user_details[:image_url] = auth[:info][:image]
        user_details[:company_name] = info[:company]
      
      else
        raise "Cannot recognize provider."
      end
      
    rescue
      if Rails.env == "development"
        raise $!.to_s
      else
        logger.debug $!.to_s
      end
    end
    
    existing_user = User.find_by_email(auth["info"]["email"])
    user = existing_user if existing_user
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
    FbGraph::Auth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"], :redirect_url =>  redirect_url)
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
    user = User.where(email: email).first
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = User.cached_find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def enrolled?(obj)
    if obj.is_a? Path
      enrollments.find_by_path_id(obj.id)
    elsif obj.is_a? Evaluation
      evaluation_enrollments.find_by_evaluation_id(obj.id)
    else
      raise "Unknown enrollment type."
    end
  end
  def enroll!(obj)
    if obj.is_a? Path
      enrollments.create!(path_id: obj.id) unless enrollments.find_by_path_id(obj.id)
    elsif obj.is_a? Persona
      user_personas.create!(persona_id: obj.id) unless user_personas.find_by_persona_id(obj.id)
    elsif obj.is_a? Evaluation
      evaluation_enrollments.create!(evaluation_id: obj.id) unless evaluation_enrollments.find_by_evaluation_id(obj.id)
    else
      raise "Invalid object to enroll."
    end
  end
  def unenroll!(path) enrollments.find_by_path_id(path.id).destroy end
  
  def award_points(obj, points)
    if points.to_i > 0
      if obj.is_a? CompletedTask
        task_id = obj.task_id
      elsif obj.is_a? Vote
        task_id = obj.owner.task_id
      elsif obj.is_a? Task
        task = obj
      else
        raise "unknown object"
      end
      task = Task.cached_find(task_id) unless task
      enrollment = enrollments.find_by_path_id(task.path_id)
      unless enrollment
        raise "Enrollment nil: "+task.to_yaml
      end 
      log_transaction(obj, points)
      self.earned_points = self.earned_points + points
      self.content_creation_enabled_at = Time.now
      self.save!
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
  
  def can_email?(type = nil)
    if locked?
      puts "User is locked"
      return false
    end
    
    if (last_email_sent_at && last_email_sent_at.to_date.today?)
      if emails_today && emails_today >= MAX_DAILY_EMAILS
        #puts "Emailed too much today"
        return false
      else
        #puts "Can send email."
        return true
      end
    else
      self.emails_today = 0
      save!
    end
    
    settings = notification_settings
    return false if settings.inactive
    return false if type == :interaction && !settings.interaction
    return false if type == :powers && !settings.powers
    return false if type == :weekly && !settings.weekly
    return true
  end
  
  def log_email(m)
    if last_email_sent_at && last_email_sent_at.to_date.today?
      self.emails_today += 1
    else
      self.emails_today = 1
    end
    
    self.last_email_sent_at = DateTime.now
    self.save!
    
    SentEmail.create!(user_id: self.id, content: m.subject)
    
    return self
  end
  
  def vote_list
    votes.to_a.collect {|v| v.owner_id }
  end
  
  def self.reputation_badge(earned_points)
    earned_points = earned_points.to_i
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
  
  def following?(user)
    user = user.id unless user.is_a? Integer
    subscriptions.find_by_followed_id(user)
  end
  def follow!(user) 
    user = user.id unless user.is_a? Integer
    subscriptions.create!(followed_id: user)
  end
  def unfollow!(user) 
    user = user.id unless user.is_a? Integer
    following?(user).destroy
  end
  def follower_count() subscribers.count end
  def following_count() subscriptions.count end
  
  def self.grant_anon_username() USERNAME_ADJS.shuffle.first.capitalize + USERNAME_NOUNS.shuffle.first.capitalize + rand(500).to_s end
  
  def to_json
    all_enrollments = enrollments.where("total_points > ?", 0)
      .joins(:path)
      .select("enrollments.id, enrollments.metascore, enrollments.metapercentile, enrollments.total_points, paths.image_url as challenge_picture, paths.name as challenge_name")
      .where("paths.approved_at is not ? and published_at is not ?", nil, nil)
    
    results = { id: self.id, username: self.username, email: self.email, name: self.name, picture: self.image_url }
    results[:challenges] = all_enrollments.collect do |e|
       { name: e.challenge_name,
         picture: e.challenge_picture, 
         points: e.total_points,
         metascore: e.metascore,
         percentile: e.metapercentile,
         answers: e.completed_tasks.count }
    end
    return results
  end
  
  def employer?
    group_users.where(is_admin: true).count > 0
  end
  
  def send_test_alert(email_type = :interaction)
    Mailer.test_alert(self, email_type).deliver
  end
  
  # Cached methods
  
  def self.cached_find_by_id(id)
    return nil unless id
    Rails.cache.fetch([self.to_s, id]) { where(id: id).first }
  end
  
  def self.cached_find_by_username(username)
    Rails.cache.fetch([self.to_s, username]) { where(username: username).first }
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name, username])
    Rails.cache.delete([self.class.name, id])
    return true
  end
  
  private  
  def check_image_url() self.image_url = nil if self.image_url && self.image_url.length < 9 end
  
  def encrypt(string) secure_hash("#{salt}--#{string}") end
  def make_salt() secure_hash("#{Time.now.utc}--#{password}") end
  def secure_hash(string) Digest::SHA2.hexdigest(string) end
  
  def log_transaction(obj, points)
    user_transactions.create!(owner_id: obj.id, owner_type: obj.class.to_s, amount: points, status: 1)
  end
end