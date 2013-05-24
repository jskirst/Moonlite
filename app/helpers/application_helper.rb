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
  
  def social_details(post)
    { 
      owner_has_comments: post["has_comments"],
      owner_type: "SubmittedAnswer", 
      owner_id: post["submitted_answer_id"],
      created_at: post["created_at"], 
      sharing_url: submission_details_url(post["path_permalink"], post["submitted_answer_id"]), 
      sharing_title: "Great response in the #{post["path_name"]} Challenge on @MetaBright." 
    } 
  end
  
  def idea_comment_details(idea)
    { 
      owner_has_comments: "t",
      owner: idea, 
      owner_type: "Idea", 
      owner_id: idea.id, 
      comment_count: idea.comments.size, 
      created_at: idea.created_at, 
      sharing_url: idea_path(idea), 
      sharing_title: "Great idea for a feature on @MetaBright!" 
    } 
  end
  
  def popup_javascript(url)
    "javascript:void window.open('#{url}','sharing','width=550,height=300,toolbar=0,menubar=0,location=0,status=0,scrollbars=0,resizable=1,left=0,top=0');return false;"
  end
  
  def sharing_popup_javascript(destination, url, text = "")
    url = case destination
      when :facebook
        "https://www.facebook.com/sharer/sharer.php?u=#{url}"
      when :twitter
        "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}&url=#{url}"
      when :google_plus
        "https://plus.google.com/share?url=#{url}"
      end
    popup_javascript(url)
  end
  
  def admin_tabs
    [
      ["overview", "Overview", admin_overview_path],
      ["funnel", "Funnel", admin_funnel_path],
      ["roles", "User Roles", user_roles_path],
      ["styles", "Custom Styles", admin_styles_path],
      ["personas", "Personas", personas_path],
      ["paths", "Paths", admin_paths_path],
      ["users", "Users", admin_users_path],
      ["submissions", "Submissions", admin_submissions_path],
      ["tasks", "Tasks", admin_tasks_path],
      ["comments", "Comments", admin_comments_path]
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
      questions_pop: {
        content: "Create questions for your Challenge here.",
        placement: "bottom"
      },
      challenge_desc_pop: {
        content: "Every Challenge needs a description.",
        placement: "bottom"
      },
      section_settings_pop: {
        content: "Publish your section before you publish your Challenge.",
        placement: "right"
      }
      
      #,
      # editor_link: {
        # content: "Choose a tab and start creating questions!",
        # placement: "right"  
      # }
    }
  end
  
  def hash_to_array(hash)
    hash.collect{ |k, v| [v, k] }
  end
  
  def when_count(query, table = nil, start_time = nil, end_time = nil)
    if table
      if start_time
        query = query.where("#{table.to_s}.created_at >= ?", start_time)
      end
      if end_time
        query = query.where("#{table.to_s}.created_at <= ?", end_time)
      end
    end
    query.count
  end
  
  def newsfeed_fields
    %Q[ 
      completed_tasks.id as id, completed_tasks.created_at as created_at, completed_tasks.points_awarded, completed_tasks.status_id,
      paths.id as path_id, paths.name as path_name, paths.permalink as path_permalink, 
      submitted_answers.id as submitted_answer_id, submitted_answers.total_votes as total_votes, 
        submitted_answers.content as submitted_answer_content, submitted_answers.caption as submitted_answer_caption,
        submitted_answers.has_comments as has_comments, submitted_answers.promoted_at as promoted_at,
      tasks.id as task_id, tasks.section_id, tasks.question as question, tasks.answer_type as answer_type, tasks.answer_sub_type as answer_sub_type, 
      users.id as user_id, users.username, users.name, users.image_url as user_image_url, users.earned_points
    ]
  end
end
