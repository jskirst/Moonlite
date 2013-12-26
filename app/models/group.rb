class Group < ActiveRecord::Base
  def to_param
    permalink
  end
  
  FREE_PLAN = "free_to_demo"
  SINGLE_PLAN = "single"
  TWO_TO_FIVE_PLAN = "two_to_five"
  SIX_TO_FIFTEEN_PLAN = "six_to_fifteen"
  SIXTEEN_TO_FIFTY_PLAN = "sixteen_to_fifty"
  PLAN_TYPES = {
    FREE_PLAN => { price: 0.00, description: "Trial Admin", max_seats: 1, active: false },
    SINGLE_PLAN => { price: 19.99, description: "1 Admin", max_seats: 1, active: true }, 
    TWO_TO_FIVE_PLAN => { price: 29.99, description: "2-5 Admins", max_seats: 5, active: true }, 
    SIX_TO_FIFTEEN_PLAN => { price: 49.99, description: "6-15 Admins", max_seats: 15, active: true },
    SIXTEEN_TO_FIFTY_PLAN => { price: 89.99, description: "16-50 Admins", max_seats: 50, active: true }
  }
  PLAN_TYPE_LIST = PLAN_TYPES.collect{ |name, details| ["#{details[:description]} ($#{details[:price]})", name] }
  ACTIVE_PLAN_TYPE_LIST = PLAN_TYPES.select{ |name, details| details[:active] == true }.collect{ |name, details| ["#{details[:description]} (#{details[:price]})", name] }

  TRIAL_CANDIDATE_LIMIT = 1
  
  attr_accessor :creator_name, :creator_email, :creator_password, :creator, :coupon
  attr_protected :token
  attr_accessible :name,
    :description, 
    :image_url,
    :website,  
    :city,
    :state,
    :country,
    :permalink,
    :is_private,
    :creator_name, 
    :creator_email, 
    :creator_password, 
    :creator,
    :plan_type,
    :stripe_token,
    :coupon
  
  has_one   :custom_style, as: :owner
  has_many  :group_users, dependent: :destroy
  has_many  :paths
  has_many  :evaluations
  has_many  :users, through: :group_users
   
  validates_presence_of :name
  validates :plan_type, inclusion: { in: PLAN_TYPES }
   
  before_create :init_group
  after_create :add_group_creator

  def price(percent_off = nil)
    price = PLAN_TYPES[self.plan_type][:price]
    if percent_off
      price = (price * (1 - (percent_off.to_f / 100))).round(2)
    end
    return price
  end

  def init_group
    existing_user = User.find_by_email(self.creator_email)
    if existing_user
      self.creator = existing_user
      if self.creator.groups.count > 0
        self.creator.errors[:base] << "This email address is already registered to another account."
        return false
      end
    else
      self.creator = User.create_with_nothing({"name" => self.creator_name, "email" => self.creator_email, "password" => self.creator_password})
    end
    
    unless self.creator.valid?
      return false
    end
    
    grant_permalink
    grant_token
  end

  def add_group_creator
    if self.creator
      gu = group_users.new(user_id: creator.id)
      gu.is_admin = true
      gu.save!
    end
  end
  
  def save_with_stripe(stripe_card_token)
    begin
      if self.creator_email
        email = self.creator_email
      else
        email = self.users.first.email
      end
      customer_details = { description: self.id, plan: self.plan_type, card: stripe_card_token, email: email }
      customer_details[:coupon] = self.coupon if self.coupon.present?
      customer = Stripe::Customer.create(customer_details)
      self.stripe_token = customer.id
      save!
    rescue
      self.errors[:base] << "There was an error processing your card. Please try again with a different credit card."
    end
    return self.errors.size > 0
  end
  
  def admins
    users.joins(:group_users).where("group_users.is_admin = ?", true)
  end
   
  def picture
    return image_url unless image_url.blank?
    return ICON_DEFAULT_PROFILE
  end
   
  def membership(user)
    group_users.find_by_user_id(user)
  end
  
  def candidate_count
    new_sum = 0
    evaluations.each do |e|
      sum = e.evaluation_enrollments.where("submitted_at IS NOT NULL").count
      new_sum = sum + new_sum
    end
    return new_sum.to_s
  end
  
  def admin?(user)
    m = membership(user)
    return false if m.nil?
    return m.is_admin?
  end
  
  def private?() is_private == true end
    
  def can_add_users?() users.count < PLAN_TYPES[self.plan_type][:max_seats] end
  def seats_available() PLAN_TYPES[self.plan_type][:max_seats] - users.count end
  def requires_payment?() self.plan_type != FREE_PLAN and self.stripe_token.nil? end

  def is_trial? 
    return true if self.plan_type == FREE_PLAN
  end

  def available_evaluations?
    return true unless self.plan_type == FREE_PLAN
    return evaluations.size < 3
  end
  
  # Cached methods
  
  def self.cached_find_by_user_id(user_id)
    Rails.cache.fetch([self.to_s, "user", user_id]) do
      Group.joins("JOIN group_users on group_users.group_id=groups.id")
        .where("group_users.user_id = ?", user_id)
        .to_a
    end
  end
  
  # Mail Alert
  
  def self.new_groups(time)
    where("created_at > ?",time)
  end
  
  def send_welcome_email(deliver = false)
    m = GroupMailer.welcome(self)
    m.deliver if deliver
  end
  
  def self.send_all_welcome_emails(time, deliver = false)
    new_groups(time).each { |g| g.send_welcome_email(deliver) }
  end
   
  private
  
  def grant_permalink
    if self.permalink.blank?
      new_permalink = self.name.downcase.gsub(/[^a-z0-9]/,'')
      new_combined_permalink = new_permalink
      permalink_count = Path.where(permalink: new_combined_permalink).size
      while Group.where(permalink: new_combined_permalink).size > 0
        permalink_count += 1
        new_combined_permalink = "#{new_permalink}#{permalink_count}"
      end
      self.permalink = new_combined_permalink
    end
  end
  
  def grant_token
    if token.blank?
      self.token = SecureRandom::hex(8)
    end
    return self.token
  end
end