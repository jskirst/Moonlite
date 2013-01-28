module ApplicationHelper
  def title
    if unread_notification_count > 0
      base_title = "MetaBright (#{unread_notification_count})"
    else
      base_title = "MetaBright"
    end
    
    if @title.nil?
      base_title
    else
      base_title + " | " + @title
    end
  end
  
  def social_tags(title = nil, image = nil, description = nil)
    @social_title = title
    @social_description = description
    @social_image = image
  end
  
  def social_details(completed_task)
    { 
      owner: completed_task.submitted_answer, 
      owner_type: "SubmittedAnswer", 
      owner_id: completed_task.submitted_answer_id, 
      comment_count: completed_task.submitted_answer.comments.size, 
      created_at: completed_task.created_at, 
      sharing_url: submission_details_url(completed_task.path.permalink, completed_task.submitted_answer.id), 
      sharing_title: "Great response in the #{completed_task.path.name} Challenge on @MetaBright." 
    } 
  end
  
  def admin_tabs
    [
      ["overview", "Overview", admin_overview_path],
      ["roles", "User Roles", user_roles_path],
      ["styles", "Custom Styles", admin_styles_path],
      ["personas", "Personas", personas_path],
      ["paths", "Paths", admin_paths_path],
      ["users", "Users", admin_users_path],
      ["submissions", "Submissions", admin_submissions_path],
      ["tasks", "Tasks", admin_tasks_path]
    ]
  end
  
  def get_all_help
    {
      leaderboard_pop: {
        content: "People who have dominated this Challenge appear here.",
        placement: "left"
      },
      points_pop: {
        content: "Vote on answers you like so they earn more points.",
        placement: "right"
      },
      cr_pop: {
        content: "This is an answer to the above Creative Response question.",
        placement: "left"
      },
      editor_link: {
        content: "Choose a tab and start creating questions!",
        placement: "right"  
      }
    }
  end
end
