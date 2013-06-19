class EvaluationPath < ActiveRecord::Base

  attr_accessible :evaluation_id,
    :path_id
  
  belongs_to :evaluation
  belongs_to :path
      
end