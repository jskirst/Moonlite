class Leaderboard < ActiveRecord::Base
  attr_accessible :user_id, :completed_tasks, :category_id, :path_id, :section_id, :score, :created_at
	
	belongs_to :user
	belongs_to :category
	belongs_to :path
	belongs_to :section
  
  validates :user_id, 
    :presence => true
	validates :completed_tasks, 
    :presence => true,
    :numericality	=> true
	validates :score, 
    :presence => true,
    :numericality	=> true
		
	def self.get_all_excluded_users(company)
		excluded_emails = ""
		company.paths.each do |p|
			excluded_emails += p.excluded_from_leaderboards.to_s
		end
		return excluded_emails
	end
				
	def self.get_overall_leaderboard(company, date = nil)
		date = get_most_recent_board_date if date.nil?
		return Leaderboard.joins(:user).where("users.company_id = ? and category_id is ? and path_id is ? and section_id is ?", company.id, nil, nil, nil).all(:order => "score DESC")
	end
	
	def self.get_leaderboard_for_category(category, date = nil)
		date = get_most_recent_board_date if date.nil?
		return Leaderboard.includes(:user).where("category_id = ?", category.id).all(:order => "score DESC")
	end
	
	def self.get_leaderboards_for_path(path, get_sections = true)
		sections = path.sections
		leaderboards = []
		overall_leaderboard = Leaderboard.includes(:user).where("path_id = ?", path.id).all(:order => "score DESC")
		leaderboards << ["overall", overall_leaderboard]
		if get_sections
			sections.each do |s|
				sl = Leaderboard.includes(:user).where("section_id = ?", s.id).all(:order => "score DESC")
				leaderboards << [s.id, sl]
			end
		end
		return leaderboards
	end
	
	def self.get_most_recent_board_date
		previous_board = Leaderboard.first(:order => "created_at DESC")
    latest_date = previous_board.nil? ? Time.now : previous_board.created_at
    return latest_date
	end
  
  def self.get_rank(user, date = nil)
    date = get_most_recent_board_date if date.nil?
    return Leaderboard.where(["created_at = ? and score > ? and category_id is ? and path_id is ? and section_id is ?", date, user.earned_points, nil, nil, nil]).count(:order => "score DESC") + 1
  end
	
	def self.reset_leaderboard
		Leaderboard.delete_all
		date = Time.now
		User.all.each do |u|
			get_user_stats(u, date)
		end
	end
	
	def self.reset_for_path(path)
		date = Time.now
		excluded_users = path.excluded_from_leaderboards
		path.enrolled_users.each do |u|
			l = u.leaderboards.find_by_path_id(path.id)
			l.destroy unless l.nil?
			unless excluded_users.blank?
				next if excluded_users.include?(u.email)
			end
			total_path_tasks = 0
			total_path_points = 0
			path.sections.each do |s|
				total_section_tasks = 0
				total_section_points = 0
				tasks = u.completed_tasks.includes(:section).where("sections.id = ? and status_id = 1", s.id)
				total_section_tasks = tasks.size
				tasks.each {|t| total_section_points += t.points_awarded}
				l = u.leaderboards.find_by_section_id(s.id)
				l.destroy unless l.nil?
				Leaderboard.create!(:user_id => u.id, :section_id => s.id, :completed_tasks => total_section_tasks, :score => total_section_points, :created_at => date)
				total_path_tasks += total_section_tasks
				total_path_points += total_section_points
			end
			Leaderboard.create!(:user_id => u.id, :path_id => path.id, :completed_tasks => total_path_tasks, :score => total_path_points, :created_at => date)
		end
	end
	
	def self.get_user_stats(user, date)
		excluded_emails = get_all_excluded_users(user.company)
		return nil if excluded_emails.include?(user.email)
		return nil if user.name == "pending"
		
		total_tasks = 0
		total_points = 0
		categories = user.company.categories
		categories.each do |c|
			total_category_tasks = 0
			total_category_points = 0
			paths = c.paths
			paths.each do |p|
				next unless user.enrolled?(p)
				unless p.excluded_from_leaderboards.blank?
					next if p.excluded_from_leaderboards.include?(user.email)
				end
				total_path_tasks = 0
				logger.debug p.name
				path_sections = p.sections
				path_sections.each do |s|
					total_section_tasks = 0
					tasks = user.completed_tasks.includes(:section).where("sections.id = ? and status_id = 1", s.id)
					total_section_tasks = tasks.size
					total_section_points = 0
					tasks.each {|t| total_section_points += t.points_awarded}
					Leaderboard.create!(:user_id => user.id, :section_id => s.id, :completed_tasks => total_section_tasks, :score => total_section_points, :created_at => date)
					total_path_tasks += total_section_tasks
				end
				enrollment = user.enrollments.where("path_id = ?", p.id).first
				total_path_points = enrollment.total_points
				Leaderboard.create!(:user_id => user.id, :path_id => p.id, :completed_tasks => total_path_tasks, :score => total_path_points, :created_at => date)
				total_category_tasks += total_path_tasks
				total_category_points += total_path_points
			end
			Leaderboard.create!(:user_id => user.id, :category_id => c.id, :completed_tasks => total_category_tasks, :score => total_category_points, :created_at => date)
			total_tasks += total_category_tasks
			total_points += total_category_points
		end
		Leaderboard.create!(:user_id => user.id, :completed_tasks => total_tasks, :score => total_points, :created_at => date)
	end
end
