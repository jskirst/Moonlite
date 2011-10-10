class CompletedTask < ActiveRecord::Base
	attr_accessible :task_id
	
	belongs_to :user
	belongs_to :task
	
	validates :user_id, :presence => true, :uniqueness => { :scope => :task_id }
	validates :task_id, :presence => true, :uniqueness => { :scope => :user_id }
end
