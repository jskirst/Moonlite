class Opportunity
  EVAL_BASIC  = 0
  EVAL_PRO    = 1
  EVAL_ENT    = 2
  EVAL_ULTRA  = 3
  MINER_BASIC = 4
  MINER_PRO   = 5
  MINER_ENT   = 6
  MINER_ULTRA = 7
  
  PRODUCTS = {
    EVAL_BASIC => "Evaluator - Basic", EVAL_PRO => "Evaluator - Professional", EVAL_ENT => "Evaluator - Enterprise", EVAL_ULTRA => "Evaluator - Ultimate",
    MINER_BASIC => "Talent Miner - Basic", MINER_PRO => "Talent Miner - Professional", MINER_ENT => "Talent Miner - Enterprise", MINER_ULTRA => "Talent Miner - Ultimate", 
  }
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :name, :company, :email, :phone, :product
  
  validates_presence_of :name
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end