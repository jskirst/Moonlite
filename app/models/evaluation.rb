class Evaluation < ActiveRecord::Base
  attr_protected :user_id
  attr_accessible :title,
    :company,
    :link,
    :permalink
  
  belongs_to :user 
  
end