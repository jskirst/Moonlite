class CompletedTask < ActiveRecord::Base
	attr_accessible :task_id, :status_id, :quiz_session, :updated_at
	
	belongs_to :user
	belongs_to :task
	has_one :section, :through => :task
	has_one :path, :through => :section
	
	validates :user_id, :presence => true
	validates :task_id, :presence => true
	validates :status_id, :presence => true
	validates :quiz_session, :presence => true

end
