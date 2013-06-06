class CustomStyle < ActiveRecord::Base
  OFF = 0
  PREVIEW = 1
  ON = 2
  
  attr_protected :owner_id, :owner_type
  attr_accessible :mode, :styles
  
  belongs_to :owner, polymorphic: true
  
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :mode, numericality: { less_than_or_equal_to: 2, greater_than_or_equal_to: 0  }

  def off?() return mode == OFF end
  def preview?() return mode == PREVIEW end
  def on?() return mode == ON end
end
