class CustomStyle < ActiveRecord::Base
  attr_accessible :company_id, :mode, :styles
  
  belongs_to :company
  
  validates :company_id, presence: true
  
  validates :mode, numericality: { less_than_or_equal_to: 2, greater_than_or_equal_to: 0  }
end
