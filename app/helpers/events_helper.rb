module EventsHelper
  def check_achievements(new_points, enrollment)
    achievements = { level: false, rank: false, contribution: false }
    path = enrollment.path
    current_score = enrollment.total_points
    previous_score = current_score - new_points
    
    # NEW LEVEL
    current_level = enrollment.level
    previous_level = Enrollment.points_to_level(previous_score)
    if current_level > previous_level
      achievements[:level] = current_level
    end

    # CONTRIBUTION UNLOCK
    if current_score >= 1500 and previous_score < 1500
      achievements[:contribution] = true
    end
    
    # NEW RANK
    current_rank = enrollment.rank
    previous_rank = Enrollment.rank(previous_score, enrollment.path_id)
    achievements[:rank] = 100 if current_rank <= 100 and previous_rank > 100
    achievements[:rank] = 50  if current_rank <= 50 and previous_rank > 50
    achievements[:rank] = 25  if current_rank <= 25 and previous_rank > 25
    achievements[:rank] = 10  if current_rank <= 10 and previous_rank > 10
    achievements[:rank] = 5  if current_rank <= 5 and previous_rank > 5

    # NEW HIGHEST RANK
    if current_rank > enrollment.highest_rank.to_i
      enrollment.update_attribute(:highest_rank, current_rank)
    end

    return achievements
  end

  def check_for_and_create_events(new_points, enrollment)
    achievements = check_achievements(new_points, enrollment)
    events = []
    # NEW RANK
    if achievements[:rank]
      content = "#{enrollment.user.name} just broke into the Top #{achievements[:rank]} on the #{enrollment.path.name} Challenge Leaderboard."
      unless UserEvent.where(content: content).count > 0
        events << UserEvent.create! do |ue|
          ue.user = enrollment.user
          ue.path = enrollment.path
          ue.content = content
          ue.image_link = UserEvent.user_event_icon(:new_path)
          ue.action_text = "Check out #{enrollment.user.name.split.first}'s profile."
          ue.link = profile_path(enrollment.user.username)
        end
      end
    else
      #Things
    end
    return events
  end
end