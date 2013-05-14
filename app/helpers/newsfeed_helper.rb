module NewsfeedHelper
  class Feed
    MAX_POSTS = 15
    
    attr_accessor :posts, :votes, :url, :page, :context
    
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