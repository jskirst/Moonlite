class Leaderboard < ActiveRecord::Base
  attr_accessible :user_id, :completed_tasks, :category_id, :path_id, :section_id, :score, :created_at
  
  belongs_to :user
  belongs_to :category
  belongs_to :path
  belongs_to :section
  
  validates :user_id, presence: true
  validates :completed_tasks, numericality: true
  validates :score, numericality: true
  
  def self.reset_for_path_user(path, user)
    user.leaderboards.where("path_id = ?", path.id).destroy_all
    return false unless user.enrolled?(path)
    return false if user.is_test_user
    
    date = Time.now
    total_path_tasks = 0
    total_path_points = 0
    path.sections.each do |s|
      total_section_tasks = 0
      total_section_points = 0
      tasks = user.completed_tasks.includes(:section).where("sections.id = ? and status_id = 1", s.id)
      total_section_tasks = tasks.size
      tasks.each {|t| total_section_points += t.points_awarded.to_i}
      l = user.leaderboards.find_by_section_id(s.id)
      l.destroy unless l.nil?
      Leaderboard.create!(:user_id => user.id, :section_id => s.id, :completed_tasks => total_section_tasks, :score => total_section_points, :created_at => date)
      total_path_tasks += total_section_tasks
      total_path_points += total_section_points
    end
    return Leaderboard.create!(:user_id => user.id, :path_id => path.id, :completed_tasks => total_path_tasks, :score => total_path_points, :created_at => date)
  end
end