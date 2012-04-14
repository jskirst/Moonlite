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
		
	def self.get_overall_leaderboard(company, date = nil)
		date = get_most_recent_board_date if date.nil?
		return Leaderboard.joins(:user).where("users.company_id = ? and leaderboards.created_at = ? and category_id is ? and path_id is ? and section_id is ?", company.id, date, nil, nil, nil).all(:order => "score DESC")
	end
	
	def self.get_leaderboard_for_category(category, date = nil)
		date = get_most_recent_board_date if date.nil?
		return Leaderboard.includes(:user).where("created_at = ? and category_id = ?", date, category.id).all(:order => "score DESC")
	end
	
	def self.get_leaderboards_for_path(path, date = nil)
		sections = path.sections
		date = get_most_recent_board_date if date.nil?
		leaderboards = []
		overall_leaderboard = Leaderboard.includes(:user).where("created_at = ? and path_id = ?", date, path.id).all(:order => "score DESC")
		leaderboards << ["overall", overall_leaderboard]
		sections.each do |s|
			sl = Leaderboard.includes(:user).where("created_at = ? and section_id = ?", date, s.id).all(:order => "score DESC")
			leaderboards << [s.id, sl]
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
	
	def self.get_user_stats(user, date)
		completed_tasks = user.completed_tasks.size
    score = user.earned_points
    Leaderboard.create!(:user_id => user.id, :completed_tasks => completed_tasks, :score => score, :created_at => date)
		
		total_tasks = 0
		categories = user.company.categories
		categories.each do |c|
			total_category_tasks = 0
			paths = c.paths
			paths.each do |p|
				next unless user.enrolled?(p)
				total_path_tasks = 0
				logger.debug p.name
				path_sections = p.sections
				path_sections.each do |s|
					total_section_tasks = 0
					tasks = user.completed_tasks.includes(:section).where("sections.id = ?", s.id)
					total_section_tasks = tasks.size
					logger.debug s.name
					logger.debug tasks.size
					Leaderboard.create!(:user_id => user.id, :section_id => s.id, :completed_tasks => total_section_tasks, :score => total_section_tasks * 10, :created_at => date)
					total_path_tasks += total_section_tasks
				end
				Leaderboard.create!(:user_id => user.id, :path_id => p.id, :completed_tasks => total_path_tasks, :score => total_path_tasks * 10, :created_at => date)
				total_category_tasks += total_path_tasks
			end
			Leaderboard.create!(:user_id => user.id, :category_id => c.id, :completed_tasks => total_category_tasks, :score => total_category_tasks * 10, :created_at => date)
			total_tasks += total_category_tasks
		end
		Leaderboard.create!(:user_id => user.id, :completed_tasks => total_tasks, :score => total_tasks * 10, :created_at => date, :path_id => nil, :category_id => nil, :section_id => nil)
	end
end
