class Group < ActiveRecord::Base
  attr_protected :permalink, :token
  attr_accessible :name,
    :description, 
    :image_url,
    :website,  
    :city,
    :state,
    :country
  
 has_many :group_users
 has_many :users, through: :group_users
 
 validates_presence_of :name
 validates_presence_of :description
 
 def picture
   return image_url unless image_url.blank?
   return ICON_DEFAULT_PROFILE
 end
 
end
 