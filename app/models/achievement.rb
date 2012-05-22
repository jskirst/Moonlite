class Achievement < ActiveRecord::Base
  attr_accessible :name, :description, :criteria, :points, :path_id, :image_url
  
  belongs_to  :path
  has_many    :user_achievements, :include => :user
  
  validates :name, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :description, 
    :presence     => true,
    :length      => { :within => 1..255 }
    
  validates :criteria,
    :presence     => true
  
  validates :points, 
    :presence     => true
    
  validates :path_id, :presence => true
  
  def pic
    if self.image_url != nil
      return self.image_url
    else
      return "/images/default_achievement_pic.jpg"
    end
  end
  
  default_scope :order => 'points ASC'
end
