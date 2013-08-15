class Company < ActiveRecord::Base
  attr_protected :seat_limit, :enable_traditional_explore, :referrer_url
  attr_accessible :name, 
    :default_profile_picture_link, 
    :name_for_paths,
    :home_title,
    :home_subtitle,
    :home_paragraph,
    :big_logo_link,
    :small_logo_link,
    :enable_custom_landing,
    :user_role_id,
    :custom_email_from
  
  has_many :users
  has_many :paths, conditions: ["published_at is not ? and approved_at is not ?", nil, nil]
  has_many :all_paths, class_name: "Path"
  has_many :categories
  has_many :user_roles
  has_many :personas
  has_one :user_role
  has_one :custom_style, as: :owner
  
  validates :name, presence: true, length: { maximum: 100 }
  
  after_create do
    cs = CustomStyle.new
    cs.owner_id = self.id
    cs.owner_type = "Company"
    cs.save!
    
    ur = user_roles.create!(name: "Default", enabled_administration: false)
    self.user_role_id = ur.id
    self.save!
  end
  
  def email_from
    return "metabot@metabright.com" if custom_email_from.nil?
    return custom_email_from
  end
end
