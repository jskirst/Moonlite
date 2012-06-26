class PathAchievement < ActiveRecord::Base
  attr_accessible :path_id, :achievement_id
  
  belongs_to :achievement
  belongs_to :path
  
  validates :achievement_id, :presence => true, :uniqueness => { :scope => :path_id }
  validates :path_id, :presence => true, :uniqueness => { :scope => :achievement_id }
end
