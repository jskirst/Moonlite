class Company < ActiveRecord::Base
  attr_protected :seat_limit, :user_role_id, :enable_traditional_explore, :referrer_url
  attr_accessible :name, 
    :default_profile_picture_link, 
    :name_for_paths,
    :home_title,
    :home_subtitle,
    :home_paragraph,
    :big_logo_link,
    :small_logo_link,
    :enable_custom_landing
  
  has_many :users
  has_many :rewards
  has_many :paths
  has_many :categories
  has_many :user_roles
  has_many :usage_reports
  has_many :personas
  has_one :user_role
  has_one :custom_style
  
  validates :name, presence: true, length: { :maximum => 100 }
end
