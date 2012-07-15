class Persona < ActiveRecord::Base
  attr_accessible :company_id, :name, :description, :criteria, :points

  belongs_to :company
  
  has_many :stored_resources, as: :owner 
  has_many :user_personas, include: :user
  has_many :users, through: :user_personas
  has_many :path_personas, include: :path
  has_many :paths, through: :path_personas
  
  validates :name, length: { :within => 1..255 }
  validates :description, length: { :within => 1..255 }
  validates :points, presence: true
  
  default_scope :order => 'points ASC'
    
  def pic
    return self.image_url unless self.image_url.nil?
    return "/images/default_achievement_pic.jpg"
  end
end
