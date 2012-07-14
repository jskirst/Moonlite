class Persona < ActiveRecord::Base
  attr_accessible :company_id, :name, :description, :criteria, :points

  belongs_to :company
  
  has_many :stored_resources, :as => :owner 
  
  has_many    :user_personas, :include => :user
  has_many    :users, :through => :user_personas
  
  has_many    :path_personas, :include => :path
  has_many    :paths, :through => :path_personas
  
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
