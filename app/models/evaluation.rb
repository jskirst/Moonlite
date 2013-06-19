class Evaluation < ActiveRecord::Base
  attr_accessor :selected_paths
  attr_protected :user_id
  attr_accessible :title,
    :company,
    :link,
    :permalink,
    :selected_paths
  
  belongs_to :user 
  
  has_many :evaluation_paths
  has_many :paths, through: :evaluation_paths
  
  before_create do
    self.permalink = SecureRandom.hex(6)
  end
  
  after_create do
    selected_paths.each do |id,checked|
      evaluation_paths.create!(path_id: id)
    end
  end
end