module SectionsHelper

  def create_completed_task
    if params[:task_id].nil?
      return nil, nil, nil
    elsif params[:answer].blank? && params[:text_answer].blank?
      flash.now[:error] = "You must provide an answer."
      return nil, nil, nil
    end
  
    current_task = Task.find(params[:task_id])
    if current_task.answer_type == 0
      answer = ""
      status_id = 2
      submitted_answer = current_task.find_or_create_submitted_answer(params[:answer])
      submitted_answer_id = submitted_answer.id
      chosen_answer_id = nil
    elsif current_task.answer_type >= 1
      answer = params[:answer]
      status_id, chosen_answer = current_task.is_correct?(answer)
      if chosen_answer.nil? && current_task.answer_type != 1
        raise "RUNTIME EXCEPTION: No answer found for multiple choice question for Task ##{current_task.id}"
      end
      chosen_answer_id = chosen_answer.id unless chosen_answer.nil?
      submitted_answer_id = nil
    else
      raise "RUNTIME EXCEPTION: Invalid answer type for Task ##{current_task.id.to_s}"
    end
    
    streak = current_task.section.user_streak(current_user)
    last_task_time = current_user.completed_tasks.last.created_at unless current_user.completed_tasks.empty?
    completed_task = current_user.completed_tasks.build(
      params.merge(:status_id => status_id, 
        :answer => answer, 
        :answer_id => chosen_answer_id, 
        :submitted_answer_id => submitted_answer_id))

    if status_id == 1
      points = 10
      if streak < 0
        points = points / ((streak-1) * -1)
      elsif (last_task_time || Time.now) > 40.seconds.ago
        streak += 1
        streak_points, streak_name = calculate_streak_bonus(streak, points)
        points += streak_points
      else
        points = points / 2
      end
      completed_task.points_awarded = points
      current_user.award_points_and_achievements(current_task, points)
    else
      completed_task.points_awarded = 0        
    end
    
    completed_task.save
    Answer.increment_counter(:answer_count, chosen_answer_id) if chosen_answer_id
    if streak_name && streak >= 10
      create_user_event_for_streak(streak_points, streak_name)
    end
    return completed_task, streak, streak_points, streak_name
  end
  
  def calculate_streak_bonus(streak, base_points)
    case streak
    when 3
      return base_points.to_f * 0.25, "Heating Up"
    when 5
      return base_points.to_f * 0.5, "On Fire"
    when 7
      return base_points.to_f * 0.75, "Brilliant"
    when 10
      return base_points.to_f * 1, "Unstoppable"
    when 14
      return base_points.to_f * 2, "God Like"
    when 18
      return base_points.to_f * 3, "Genuinely Impossible"
    when 22
      return base_points.to_f * 4, "What??!?!"
    when 25
      return base_points.to_f * 5, "Please stop"
    when 28
      return base_points.to_f * 6, "Look, you broke it."
    when 40
      return base_points.to_f * 7, "We don't even have a name for this"
    end
    return 0
  end
  
  private
    def create_user_event_for_streak(streak_points, streak_name)
      event = "<%u%> unlocked the <strong>#{streak_name}</strong> achievement for an extra #{streak_points.to_i.to_s} points!"
      current_user.user_events.create!(:path_id => @path.id, :content => event)
    end
end
