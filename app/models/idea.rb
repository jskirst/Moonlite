class Idea < ActiveRecord::Base
  attr_readonly :creator_id
  attr_protected :status
  attr_accessible :title, :description
  
  belongs_to :creator, class_name: "User"
  has_many :votes, as: :owner
  has_many :comments, as: :owner
  
  validates :title, length: { within: 1..255 }
  validates :description, length: { within: 1..1000 }
  validates_presence_of :creator_id
  
  def points_awarded
    votes.count * 50
  end
end
