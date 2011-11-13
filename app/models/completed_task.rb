class CompletedTask < ActiveRecord::Base
	attr_accessible :task_id, :status_id, :quiz_session
	
	belongs_to :user
	belongs_to :task
	
	validates :user_id, :presence => true
	validates :task_id, :presence => true
	validates :status_id, :presence => true
	validates :quiz_session, :presence => true
end
