class CustomStyle < ActiveRecord::Base
  include W3CValidators
  OFF = 0
  PREVIEW = 1
  ON = 2
  
  attr_protected :owner_id, :owner_type
  attr_accessible :mode, :styles
  
  belongs_to :owner, polymorphic: true
  
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :mode, numericality: { less_than_or_equal_to: 2, greater_than_or_equal_to: 0  }
  validate :validate_css

  def off?() return mode == OFF end
  def preview?() return mode == PREVIEW end
  def on?() return mode == ON end
    
  def validate_css
    return true if self.styles.blank? or self.mode == OFF
    validator = CSSValidator.new
    results = validator.validate_text(self.styles)

    if results.errors.length > 0
      self.errors[:base] << results.errors.join(". ")
      self.mode = OFF
      return false
    end
    return true
  end
  
  # Only used for initial cleanup of styles.
  def self.validate_all_styles
    where.not(styles: nil).each do |s|
      s.validate_css
      s.save!
    end
  end
end
