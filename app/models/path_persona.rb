class PathPersona < ActiveRecord::Base
  attr_accessible :path_id, :persona_id
  
  belongs_to :persona
  belongs_to :path
  
  validates :persona_id, :presence => true, :uniqueness => { :scope => :path_id }
  validates :path_id, :presence => true, :uniqueness => { :scope => :persona_id }
end
