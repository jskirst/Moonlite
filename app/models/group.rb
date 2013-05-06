class Group < ActiveRecord::Base
  attr_protected :token
  attr_accessible :name,
    :description, 
    :image_url,
    :website,  
    :city,
    :state,
    :country,
    :permalink
  
  has_many :group_users
  has_many :users, through: :group_users
   
  validates_presence_of :name
  validates_presence_of :description
   
  before_create do 
    grant_permalink
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
end
 