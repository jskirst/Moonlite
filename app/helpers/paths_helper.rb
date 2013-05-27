module PathsHelper
  
  def check_achievements(points, enrollment)
    achievements = { level: false, rank: false, contribution: false }
    
    current_score = enrollment.total_points
    previous_score = current_score - points
    
    current_level = enrollment.level
    previous_level = Enrollment.points_to_level(previous_score)
    if current_level > previous_level
      achievements[:level] = current_level
      if current_level >= 1500 and previous_level < 1500
        achievements[:contribution] = true
      end
    end 
    
    current_rank = enrollment.rank
    previous_rank = Enrollment.rank(previous_score, enrollment.path_id)
    achievements[:rank] = 100 if current_rank <= 100 and previous_rank > 100
    achievements[:rank] = 50  if current_rank <= 50 and previous_rank > 50
    achievements[:rank] = 25  if current_rank <= 25 and previous_rank > 25
    achievements[:rank] = 10  if current_rank <= 10 and previous_rank > 10
    
    return achievements
  end
  
end