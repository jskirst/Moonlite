require 'open-uri'
require 'openssl'

module PreviewHelper
  
  PREVIEWABLE = {
    "github.com" => "github"
  }
  
  def parse_url_for_preview(url)
    @url = url
    @results = {
      url: @url,
      warnings: nil,
      error: nil,
      title: nil,
      description: nil,
      content: nil,
      site_name: nil,
      image_url: nil,
      raw: nil
    }
    
    if @url.blank?
      @results[:error] = "Please supply a valid site url."
    end
    
    unless @url.include?("http://") or @url.include?("https://")
      @url = "http://#{@url}"
      @results[:url] = @url
    end
    
    begin
      data = open(@url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      @results[:raw] = data.to_s
      page = Nokogiri::HTML(data)
    rescue
      @results[:error] = "Could not load page"
    end
    
    return @results if @results[:error]
      
    # Open Graph Tags
    tags = { title: "og:title", description: "og:description", image_url: "og:image", site_name: "og:site_name" }
    tags.each do |tag, meta_name|
      begin
        result = page.xpath("//meta[@property='#{meta_name}']/@content").first
        if result
          @results[tag] = result.content
        else
          add_warning("Could not fetch #{tag}.")
        end
      rescue
        add_warning("Could not fetch #{tag}.")
      end
    end
    
    if @results[:title].blank? && page.at_css("title")
      @results[:title] = page.at_css("title").text
    end
    
    PREVIEWABLE.each do |url_snippet, previewer|
      if @url.downcase.include?(url_snippet)
        begin
          preview = eval(previewer)
          if preview
            @results[:content] = preview.slice(0..2400)
          end
        rescue
          add_warning("Could not fetch preview.")
        end
      end
    end
    
    if @results[:warnings]
      @results[:warnings] = @results[:warnings].join(" ") 
    end
    
    return @results 
  end
  
  def add_warning(warning)
    warnings = @results[:warnings]
    if warnings.nil?
      warnings = [warning]
    else
      warnings << warning
    end
    @results[:warnings] = warnings
  end
  
  def github
    if @url.include?("blob")
      preview_url = @url.gsub("/blob", "").gsub("github.com", "raw.github.com")
      data = open(preview_url).read
      @results[:content] = data 
    end
  end
end