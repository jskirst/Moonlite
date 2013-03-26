class Comment < ActiveRecord::Base
  attr_protected :reviewed_at, :locked_at
  attr_accessible :owner_id, :owner_type, :content
  
  belongs_to :user
  belongs_to :owner, polymorphic: true

  validates :user_id, presence: true
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :content, presence: true
end
