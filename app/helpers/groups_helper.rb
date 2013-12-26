module GroupsHelper
  def candidates_check
    if @admin_group and @admin_group.plan_type == Group::FREE_PLAN
      @candidate_count = EvaluationEnrollment.joins(:evaluation)
        .where("evaluations.group_id = ?", @admin_group.id)
        .where("evaluation_enrollments.submitted_at is not NULL")
        .pluck(:user_id)
        .to_a.uniq.size
      if @candidate_count > Group::TRIAL_CANDIDATE_LIMIT
        @candidate_limit_reached = true
        flash[:error] = "You are at your limit."
      else
        @candidate_limit_reached = false
        flash[:success] = "You are not at your limit."
      end
    end
  end
end