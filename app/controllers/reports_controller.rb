class ReportsController < ApplicationController
	before_filter :authenticate
  before_filter :is_enabled
  
	def dashboard
		if !params[:time]
			@time = 7
		else
			begin
				@time = Integer(params[:time])
			rescue ArgumentError => e
				@time = 7
			end
		end
		time_sql = @time.days.ago.to_s
		
		@title = "Dashboard"
		@user_activity = [0,0,0]
		@company = current_user.company
		@company_id = @company.id.to_s
		@users = @company.users
		@paths = @company.paths.where("is_published = ? and is_locked = ?", true, false)
		
		
		completed_tasks = User.count(
			:group => "users.id",
			:joins => "LEFT JOIN completed_tasks on users.id = completed_tasks.user_id and completed_tasks.updated_at > '#{time_sql}'",
			:conditions => ["users.company_id = ? and users.is_fake_user = ?", @company_id, false]
		)
		completed_tasks.each do |cp|
			if cp[1] == 1
				@user_activity[0] = @user_activity[0] + 1
			elsif cp[1] <= 10
				@user_activity[1] = @user_activity[1] + 1
			else
				@user_activity[2] = @user_activity[2] + 1
			end
		end
		
		@tasks_completed = CompletedTask.count(
			:group => "Date(completed_tasks.updated_at)",
			:joins => "JOIN users on users.id = completed_tasks.user_id",
			:conditions => ["users.company_id = ? and completed_tasks.updated_at > ? and users.is_fake_user = ?", @company_id, time_sql, false]
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
			section_ids = []
			p.sections.each do |s|
				section_ids << s.id
			end
		
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
				:joins => "JOIN tasks on tasks.id = completed_tasks.task_id JOIN users on users.id = completed_tasks.user_id",
				:conditions => ["users.company_id = ? and tasks.section_id IN (?) and completed_tasks.updated_at > ? and users.is_fake_user = ?", @company_id, section_ids, time_sql, false]
			)
			
			path_score = CompletedTask.average("status_id",
				{ :joins => "JOIN tasks on tasks.id = completed_tasks.task_id JOIN users on users.id = completed_tasks.user_id",
				:conditions => ["users.company_id = ? and tasks.section_id IN (?) and completed_tasks.updated_at > ? and users.is_fake_user = ?", @company_id, section_ids, time_sql, false] }
      )
			if !path_score.nil?
				path_score = Integer(path_score * 100)
			end
			
			@path_statistics << [p, enrollment_statistics, path_activity, path_score]
		end
	end
	
	def details
		if !params["path_id"]
			flash[:error] = "No path argument supplied."
			redirect_to dashboard_path and return
		elsif !@path = Path.find_by_id(params[:path_id])
			flash[:error] = "Bad path argument supplied."
			redirect_to dashboard_path and return
		end
		@title = "Details"
		section_ids = []
		@path.sections.each do |s|
			section_ids << s.id if s.is_published
		end
		
		@most_incorrect_tasks = CompletedTask.all(
			:group => "tasks.id",
			:joins => "JOIN tasks on tasks.id = completed_tasks.task_id",
			:conditions => ["tasks.section_id IN (?) and status_id = 0", section_ids],
			:order => "1 desc",
			:limit => "10",
			:select => "count(*) as count, tasks.id"
		)
		
		@most_correct_tasks = CompletedTask.all(
			:group => "tasks.id",
			:joins => "JOIN tasks on tasks.id = completed_tasks.task_id",
			:conditions => ["tasks.section_id IN (?)", section_ids],
			:order => "1 asc",
			:limit => "10",
			:select => "((sum(status_id)-count(*))*-1) as count, tasks.id"
		)
	end
  
  private
    
    def is_enabled
      unless @enable_dashboard
        flash[:error] = "This feature is not currently enabled for your use."
        redirect_to root_path
      end
    end
end
