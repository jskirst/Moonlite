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
  has_many :rewards
  has_many :paths, conditions: { is_published: true, is_approved: true }
  has_many :all_paths, class_name: "Path"
  has_many :categories
  has_many :user_roles
  has_many :personas
  has_one :user_role
  has_one :custom_style
  
  validates :name, presence: true, length: { maximum: 100 }
  
  after_create do
    CustomStyle.create!(company_id: self.id)
  end
  
  def email_from
    return "metabot@metabright.com" if custom_email_from.nil?
    return custom_email_from
  end
end
