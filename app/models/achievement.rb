class Achievement < ActiveRecord::Base
  attr_accessible :company_id, :name, :description, :criteria, :points

  belongs_to :company
  has_many :stored_resources, :as => :owner 
  has_many    :user_achievements, :include => :user
  has_many    :users, :through => :user_achievements
  has_many    :path_achievements, :include => :path
  has_many    :paths, :through => :path_achievements
  
  validates :name, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :description, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :points, 
    :presence     => true
    
  def pic
    if self.image_url != nil
      return self.image_url
    else
      return "/images/default_achievement_pic.jpg"
    end
  end
  
  default_scope :order => 'points ASC'
end
