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
      @title + " | " + base_title 
    end
  end
  
  def social_tags(title = nil, image = nil, description = nil)
    @social_title = title
    @social_description = description
    @social_image = image
  end
  
  def social_details(post)
    { 
      owner_has_comments: post["total_comments"] != "0",
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
  
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
  
  def gather_answers(task)
    task = task.symbolize_keys
    answers = []
    answers << { content: task.delete(:exact1), is_correct: true } unless task[:exact1].blank?
    answers << { content: task.delete(:answer_new_1), is_correct: true } unless task[:answer_new_1].blank?
    answers << { content: task.delete(:answer_new_2), is_correct: false } unless task[:answer_new_2].blank?
    answers << { content: task.delete(:answer_new_3), is_correct: false } unless task[:answer_new_3].blank?
    answers << { content: task.delete(:answer_new_4), is_correct: false } unless task[:answer_new_4].blank?
    return answers
  end
end
