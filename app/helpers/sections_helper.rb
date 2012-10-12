module SectionsHelper
  def create_completed_task
    return nil if params[:task_id].nil?
    if params[:answer].blank? && params[:text_answer].blank?
      flash.now[:error] = "You must provide an answer."
      return nil, nil, nil
    end
  
    task = Task.find(params[:task_id])
    ct = current_user.completed_tasks.new()
    ct.task_id = task.id
    if task.answer_type == 0
      ct.status_id = 2
      submitted_answer = task.find_or_create_submitted_answer(params[:answer])
      ct.submitted_answer_id = submitted_answer.id 
    elsif task.answer_type >= 1
      ct.answer = params[:answer]
      status_id, chosen_answer = task.is_correct?(ct.answer)
      ct.status_id = status_id
      ct.answer_id = chosen_answer.id unless chosen_answer.nil?
    else
      raise "RUNTIME EXCEPTION: Invalid answer type for Task ##{task.id.to_s}"
    end
    #raise chosen_answer.to_yaml + task.to_yaml + ct.to_yaml
    
    streak = task.section.user_streak(current_user)
    last_task_time = current_user.completed_tasks.last.created_at unless current_user.completed_tasks.empty?
    if status_id == 1
      points = 10
      if @enable_leaderboard
        if streak < 0
          points = points / ((streak-1) * -1)
        elsif (last_task_time || Time.now) > task.time_limit.seconds.ago
          streak += 1
          streak_points, streak_name = calculate_streak_bonus(streak, points)
          points += streak_points
        else
          points = points / 2
        end
      end
      ct.points_awarded = points
      #TODO: move this to completed task
      current_user.award_points(task, points)
    else
      ct.points_awarded = 0
    end
    
    ct.save
    Answer.increment_counter(:answer_count, chosen_answer.id) if chosen_answer
    if @enable_leaderboard && streak_name && streak >= 10
      create_user_event_for_streak(streak_points, streak_name)
    end
    return ct, streak, streak_points, streak_name
  end
  
  def calculate_streak_bonus(streak, base_points)
    streak_bonus = STREAK_BONUSES[streak]
    return streak_bonus[0] * base_points, streak_bonus[1] if streak_bonus
    return 0
  end
  
  def get_time_remaining(task)
    last_question = current_user.completed_tasks.last
    unless last_question.nil?
      last_question = nil unless last_question.path == task.path
    end
    
    if @task.disable_time_limit
        return nil
    elsif last_question.nil? || last_question.created_at > 10.seconds.ago
      return @task.time_limit
    else
      return (@task.time_limit) - (Time.now - last_question.created_at)
    end
  end
  
  def generate_hint
    if @task.answer_type == 1 && @streak < 0
      answer = @task.correct_answer.to_s
      @streak = ((@streak+1)*-1) #converting it so it can be used in a range
      @hint = "Answer starts with '" + answer.slice(0..@streak) + "'"
    elsif @task.answer_type == 2
      previous_wrong_answers = current_user.completed_tasks.where(["completed_tasks.task_id = ? and completed_tasks.status_id = ?", @task.id, 0])
      @hints = previous_wrong_answers.to_a.collect! {|pwa| pwa.answer_id }
    end
  end
  
  private
    def create_user_event_for_streak(streak_points, streak_name)
      event = "<%u%> unlocked the <strong>#{streak_name}</strong> achievement for an extra #{streak_points.to_i.to_s} points!"
      current_user.user_events.create!(:path_id => @path.id, :content => event)
    end
end
