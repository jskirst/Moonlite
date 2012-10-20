module SectionsHelper
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
