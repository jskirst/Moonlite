if ENV['FOG_DIRECTORY']
  # Set the host name for URL creation
  SitemapGenerator::Sitemap.default_host = "http://www.metabright.com"

  # pick a place safe to write the files
  SitemapGenerator::Sitemap.public_path = 'tmp/'

  # store on S3 using Fog
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new

  # inform the map cross-linking where to find the other maps
  SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"

  # pick a namespace within your bucket to organize your maps
  SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

  SitemapGenerator::Sitemap.create do
    puts "starting sitemap create"
  
    # Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically for you.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Usage: add(path, options={})
    #        (default options are used if you don't specify)
    #
    # Defaults: :priority => 0.5, :changefreq => 'weekly',
    #           :lastmod => Time.now, :host => default_host
    #
    # Examples:
    #
    # Add '/articles'
    #
    #   add articles_path, :priority => 0.7, :changefreq => 'daily'
    #
    # Add all articles:
    #
    #   Article.find_each do |article|
    #     add article_path(article), :lastmod => article.updated_at
    #   end
    add '/evaluator', :priority => 1, :changefreq => 'daily'
    add '/pricing', :priority => 0.9, :changefreq => 'daily'
    add '/about'
    add '/challenges'
    add '/labs'
    User.where(locked_at: nil, private_at: nil).find_each do |user|
      add profile_path(user.username), :lastmod => user.updated_at, :priority => 0.8
    end
    Path.where.not(published_at: nil, approved_at: nil).where(group_id: nil).find_each do |path|
      permalink = path.permalink
      puts permalink.to_s
      add challenge_path(path.permalink), :lastmod => path.updated_at, :priority => 0.9
      path.tasks.find_each do |task|
        if task.answer_type == 0
          task.completed_tasks.find_each do |completed_task|
            user = completed_task.user
            next if user.locked? or user.private?
            next if completed_task.submitted_answer_id.nil?
            add submission_details_path(permalink, completed_task.submitted_answer_id), :lastmod => completed_task.updated_at, :priority => 0.7
          end
        end
      end
    end
  end
end