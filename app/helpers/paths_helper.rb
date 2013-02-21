module PathsHelper
  
  def check_achievement(points, enrollment)
    current_score = enrollment.total_points
    previous_score = current_score - points
    
    current_level = enrollment.level
    previous_level = Enrollment.points_to_level(previous_score)
    
    current_rank = enrollment.rank
    previous_rank = Enrollment.rank(previous_score)
    
    return false if current_level == previous_level && rank == previous 
    
    level_jump = current_level if current_level > previous_level
    
    rank_jump = 100 if rank <= 100 and previous_rank > 100
    rank_jump = 50  if rank <= 50 and previous_rank > 50
    rank_jump = 25  if rank <= 25 and previous_rank > 25
    rank_jump = 10  if rank <= 10 and previous_rank > 10
    
    return level_jump, rank_jump
  end
  
end