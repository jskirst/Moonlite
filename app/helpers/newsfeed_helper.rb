module NewsfeedHelper
  def newsfeed_fields
    %Q[ 
      completed_tasks.id as id, completed_tasks.created_at as created_at, completed_tasks.points_awarded, completed_tasks.status_id,
      paths.id as path_id, paths.name as path_name, paths.permalink as path_permalink, 
      submitted_answers.id as submitted_answer_id, submitted_answers.total_votes as total_votes, 
        submitted_answers.content as submitted_answer_content, submitted_answers.caption as submitted_answer_caption,
        submitted_answers.total_comments as total_comments, submitted_answers.promoted_at as promoted_at, submitted_answers.image_url as image_url,
        submitted_answers.title as title, submitted_answers.description as description, submitted_answers.url as url,
      tasks.id as task_id, tasks.section_id, tasks.question as question, tasks.answer_type as answer_type, tasks.answer_sub_type as answer_sub_type, 
      users.id as user_id, users.locked_at, users.private_at, users.username, users.name, users.image_url as user_image_url, users.earned_points
    ]
  end
  
  class Feed
    MAX_POSTS = 15
    
    attr_accessor :posts, :votes, :url, :page, :context, :viewing_user, :user_posts
    
    def initialize(params = nil, user = nil, url = nil, posts = [])      
      if params
        @page = params[:page].to_i
        @context = params[:action].to_sym
      end 
      
      if user
        @votes = user.votes.to_a.collect {|v| v.owner_id }
      end
      
      if url
        @url = url
      end
      
      @posts = posts
      
      if user
        @user_posts = user.creative_task_ids
      else
        @user_posts = []
      end
    end

    def posts
      @posts << OpenStruct.new(name: "Name", username: "Username", content: "This is text", user_image_url: "/dogshit", earned_points: "500", type: :event)
      @posts << OpenStruct.new(name: "Name", username: "Username", content: "This is text", user_image_url: "/dogshit", earned_points: "500", type: :event)
      @posts << OpenStruct.new(name: "Name", username: "Username", content: "This is text", user_image_url: "/dogshit", earned_points: "500", type: :event)
      @posts.shuffle!
      return @posts
    end
    
    def url=(url)
      @url = url
    end
    
    def url
      return false if @url.nil?
      if posts.size == MAX_POSTS
        @url + (@url.include?("?") ? "&" : "?") + "page=#{@page+1}"
      end
    end
  end
end