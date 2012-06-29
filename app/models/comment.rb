class Comment < ActiveRecord::Base
  attr_accessible :owner_id, :owner_type, :content
  
  belongs_to :user
  belongs_to :owner, :polymorphic => true

  validates :user_id, 
    :presence => true
  validates :owner_id, 
    :presence => true
  validates :owner_type, 
    :presence => true
  validates :content, 
    :presence => true,
    :length => { :within => 1..255 }
    
end
