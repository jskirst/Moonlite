module PathsHelper
  
  def check_achievements(points, enrollment)
    current_score = enrollment.total_points
    previous_score = current_score - points
    
    current_level = enrollment.level
    previous_level = Enrollment.points_to_level(previous_score)
    
    current_rank = enrollment.rank
    previous_rank = Enrollment.rank(previous_score, enrollment.path_id)
    
    return false if current_level == previous_level && current_rank == previous_rank 
    
    level_jump = current_level if current_level > previous_level
    
    rank_jump = 100 if current_rank <= 100 and previous_rank > 100
    rank_jump = 50  if current_rank <= 50 and previous_rank > 50
    rank_jump = 25  if current_rank <= 25 and previous_rank > 25
    rank_jump = 10  if current_rank <= 10 and previous_rank > 10
    
    return level_jump, rank_jump
  end
  
end