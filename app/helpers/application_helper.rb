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
  
  def admin_tabs
    [
      ["overview", "Overview", admin_overview_path],
      ["roles", "User Roles", user_roles_path],
      ["styles", "Custom Styles", admin_styles_path],
      ["personas", "Personas", personas_path],
      ["paths", "Paths", admin_paths_path],
      ["users", "Users", admin_users_path],
      ["submissions", "Submissions", admin_submissions_path]
    ]
  end
  
  def get_all_help
    {
      leaderboard_pop: {
        content: "The people who have dominated this Challenge appear here.",
        placement: "left"
      }
    }
  end
end
