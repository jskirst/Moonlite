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
    
    attr_accessor :posts, :submissions, :events, :votes, :url, :page, :context, :user_posts, :path_ids, :user
    
    def initialize(attrs)
      @submissions = attrs[:submissions]
      @events = attrs[:events]
      @url = attrs[:url]
      @user = attrs[:user]
      @path_ids = attrs[:path_ids]
      @context = attrs[:action].try(:to_sym)
      @page = attrs[:page].to_i
    end

    def user_posts
      @user_posts ||= (@user ? user.creative_task_ids : [])
    end

    def votes
      @votes ||= (@user ? @user.votes.to_a.collect {|v| v.owner_id } : [])
    end

    def posts
      return @posts if @posts
      @posts = []

      if @path_ids
        events = UserEvent.joins(:user)
          .where("users.email NOT LIKE ?", '%@metabright.com%')
          .where("user_events.path_id in (?)", self.path_ids)
          .includes(:user)
          .order("user_events.id DESC")

        events.each do |e|
          u = e.user
          @posts << OpenStruct.new(name: u.name, 
            username: u.username, 
            content: e.content, 
            user_image_url: u.image_url, 
            earned_points: u.earned_points,
            created_at: e.created_at, 
            link: e.link,
            image_link: e.image_link,
            action_text: e.action_text,
            type: :event)
        end
      end
      @submissions.each { |s| @posts << s }
      @posts.sort_by{ |a| a.created_at }
      return @posts
      
      # New User joined MB (only visible on homepage stream)
      # content: "#{event.name} just joined MetaBright! Give them a warm welcome."

      # Following
      # content: "#{event.name} is now following *Person2*."  

      # CR Vote
      # content: "#{event.name} voted for *Person2's* response in the *Challenge name* Challenge."

      # CR Comment
      # content: "#{event.name} commented on *Person2's* creative response."
      
      # Level up
      # content: "#{event.name} just leveled up in the *Challenge name* Challenge."
      
      # New Leaderboard ranking
      # content: "#{event.name} just broke into the top 10/50/100/500 in the *Challenge name* Challenge."
      
      # * New HoF
      # content: "#{event.name}'s creative response was just added to the *Challenge name* Hall of Fame."
      
      # * New Task created
      # content: "#{event.name} added a new question to the *Challenge name* Challenge."
      
      # New Challenge published
      # content: "#{event.name} published the *Challenge name* Challenge."
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