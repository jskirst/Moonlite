class ReportsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin

	def dashboard
		@title = "Dashboard"
		@user_activity = [0,0,0]
		@company = current_user.company
		@company_id = @company.id.to_s
		@company_users = @company.company_users
		@users = @company.users
		@paths = @company.paths
		
		completed_tasks = CompletedTask.count(
			:group => "completed_tasks.user_id",
			:joins => "JOIN company_users on company_users.user_id = completed_tasks.user_id",
			:conditions => "company_users.company_id = #{@company_id} and completed_tasks.updated_at > '" + 7.days.ago.to_s + "'"
		)
		completed_tasks.each do |cp|
			if cp[1] == 0
				@user_activity[0] = @user_activity[0] + 1
			elsif cp[1] <= 10
				@user_activity[1] = @user_activity[1] + 1
			else
				@user_activity[2] = @user_activity[2] + 1
			end
		end
		
		@tasks_completed = CompletedTask.count(
			:group => "Date(completed_tasks.updated_at)",
			:joins => "JOIN company_users on company_users.user_id = completed_tasks.user_id",
			:conditions => "company_users.company_id = #{@company_id} and completed_tasks.updated_at > '" + 7.days.ago.to_s + "'"
		)
		
		@user_points = {"0-50" => 0, "51-100" => 0, "101-500" => 0, "501-2000" => 0, "2000+" => 0 }
		@users.each do |u|
			if u.earned_points <= 50
				@user_points["0-50"] += 1
			elsif u.earned_points <= 100
				@user_points["51-100"] += 1
			elsif u.earned_points <= 500
				@user_points["101-500"] += 1
			elsif u.earned_points <= 2000
				@user_points["501-2000"] += 1
			else
				@user_points["2000+"] += 1
			end
		end
	
		@path_statistics = []
		@paths.each do |p|
			enrolled = 0
			not_enrolled = 0
			@users.each do |u|
				if u.enrolled?(p)
					enrolled += 1
				else
					not_enrolled += 1
				end
			end
			enrollment_statistics = [enrolled, not_enrolled]
			
			path_activity = CompletedTask.count(
				:group => "Date(completed_tasks.updated_at)",
				:joins => "JOIN tasks on tasks.id = completed_tasks.task_id JOIN company_users on company_users.user_id = completed_tasks.user_id",
				:conditions => "company_users.company_id = #{@company_id} and tasks.path_id = #{p.id} and completed_tasks.updated_at > '" + 7.days.ago.to_s + "'"
			)
			
			path_score = CompletedTask.average("status_id",
				{ :joins => "JOIN tasks on tasks.id = completed_tasks.task_id JOIN company_users on company_users.user_id = completed_tasks.user_id",
				:conditions => "company_users.company_id = #{@company_id} and tasks.path_id = #{p.id} and completed_tasks.updated_at > '" + 7.days.ago.to_s + "'" }
			)
			if !path_score.nil?
				path_score = Integer(path_score * 100)
			end
			
			@path_statistics << [p.name, enrollment_statistics, path_activity, path_score]
		end
	end
	
	private
		def company_admin
			redirect_to(root_path) unless current_user.company_admin?
		end
end
