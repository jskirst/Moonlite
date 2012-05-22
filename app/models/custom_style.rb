class CustomStyle < ActiveRecord::Base
  attr_protected :company_id
  attr_accessible :is_active, :core_layout_styles, :add_on_styles
  
  belongs_to :company
  
  validates :company_id, :presence => true
end
