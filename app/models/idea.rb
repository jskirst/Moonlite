class Idea < ActiveRecord::Base
  IDEA  = 0
  BUG   = 1
  TYPES = { IDEA => "Idea", BUG => "Bug" }
  
  attr_readonly :creator_id
  attr_protected :status, :vote_count
  attr_accessible :title, :description, :idea_type
  
  belongs_to :creator, class_name: "User"
  has_many :votes, as: :owner
  has_many :comments, as: :owner, conditions: ["locked_at is ?", nil]
  
  validates :title, length: { within: 1..255 }
  validates :description, length: { within: 1..1000 }
  validates_presence_of :creator_id
  
  after_create do 
    Mailer.new_idea(self).deliver
  end
  
  def idea?() self.idea_type == IDEA end
  def bug?() self.idea_type == BUG end
  
  def points_awarded
    100 + (vote_count * 50)
  end
  
  def increment_vote_count
    self.vote_count += 1
    save!
  end
  
  def decrement_vote_count
    self.vote_count -= 1
    self.vote_count = 0 if vote_count < 0
    save!
  end
end
