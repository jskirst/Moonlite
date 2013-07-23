class Group < ActiveRecord::Base
  FREE_PLAN = "free"
  SINGLE_PLAN = "single"
  TWO_TO_FIVE_PLAN = "two_to_five"
  SIX_TO_FIFTEEN_PLAN = "six_to_fifteen"
  SIXTEEN_TO_FIFTY_PLAN = "sixteen_to_fifty"
  PLAN_TYPES = {
    FREE_PLAN => { price: "Free", description: "Free trial account" }, 
    SINGLE_PLAN => { price: "$9.99", description: "Single User" }, 
    TWO_TO_FIVE_PLAN => { price: "$19.99", description: "2-5 users" }, 
    SIX_TO_FIFTEEN_PLAN => { price: "$39.99", description: "6-15 users" },
    SIXTEEN_TO_FIFTY_PLAN => { price: "$79.99", description: "16-50 users" }
  }
  
  attr_accessor :creator_name, :creator_email, :creator_password, :creator
  attr_protected :token, :plan_type
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
    :creator
  
  has_one   :custom_style, as: :owner
  has_many  :group_users
  has_many  :paths
  has_many  :evaluations
  has_many  :users, through: :group_users
   
  validates_presence_of :name
  validates :plan_type, inclusion: { in: PLAN_TYPES }
   
  before_create do
    if self.creator_name
      existing_user = User.find_by_email(self.creator_email)
      if existing_user
        self.creator = existing_user
      else
        self.creator = User.create_with_nothing({"name" => self.creator_name, "email" => self.creator_email, "password" => self.creator_password})
      end
    end
    if self.creator.nil?
      raise "No Creator"
    end
    grant_permalink
    grant_token
  end
  
  after_create do
    if self.creator
      gu = group_users.new(user_id: creator.id)
      gu.is_admin = true
      gu.save!
    end
  end
  
  def save_with_stripe(stripe_card_token)
    begin
      customer = Stripe::Customer.create(description: self.id, plan: self.plan_type, card: stripe_card_token)
      self.stripe_token = customer.id
      save!
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      false
    end
  end
   
  def picture
    return image_url unless image_url.blank?
    return ICON_DEFAULT_PROFILE
  end
   
  def membership(user)
    group_users.find_by_user_id(user)
  end
  
  def admin?(user)
    m = membership(user)
    return false if m.nil?
    return m.is_admin?
  end
  
  def private?() is_private == true end
  
  # Cached methods
  
  def self.cached_find_by_user_id(user_id)
    Rails.cache.fetch([self.to_s, "user", user_id]) do
      Group.joins("JOIN group_users on group_users.group_id=groups.id")
        .where("group_users.user_id = ?", user_id)
        .to_a
    end
  end
   
  private
  
  def grant_permalink
    if self.permalink.blank?
      new_permalink = self.name.downcase.gsub(/[^a-z0-9]/,'')
      new_combined_permalink = new_permalink
      permalink_count = Path.where(permalink: new_combined_permalink).size
      while Path.where(permalink: new_combined_permalink).size > 0
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
 