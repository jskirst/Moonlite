class Comment < ActiveRecord::Base
  attr_protected :reviewed_at, :locked_at
  attr_accessible :owner_id, :owner_type, :content
  
  belongs_to :user
  belongs_to :owner, polymorphic: true

  validates :user_id, presence: true
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :content, presence: true
  
  after_save :flush_cache
  before_destroy :flush_cache
  
  # Cached method
  
  def self.cached_find_by_owner_type_and_owner_id(ot, oid)
    Rails.cache.fetch([self.class.to_s, ot, oid]) do
      Comment.where(owner_type: ot, owner_id: oid).where("locked_at is ?", nil).to_a
    end
  end
  
  def flush_cache
    Rails.cache.delete([self.class.to_s, owner_type, owner_id])
  end
end
