class Reward < ActiveRecord::Base
  attr_accessible :name, :description, :image_url, :points
  
  belongs_to :company
  
  validates :name, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :description, 
    :presence     => true,
    :length      => { :within => 1..255 }
    
  validates :image_url,
    :presence     => true,
    :length      => { :within => 15..255 }
    
  validates :points, 
    :presence     => true,
    :numericality  => { :less_than => 100000 }
  
  validates :company_id, :presence => true
  
  default_scope :order => 'rewards.points ASC'
  
end
