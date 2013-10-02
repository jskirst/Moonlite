module GzipStreaming
  def _process_options(options)
    stream = options[:stream]
    # delete the option to stop original implementation  
    options.delete(:stream)
    super
    if stream && env["HTTP_VERSION"] != "HTTP/1.0"
      # Same as org implmenation except don't set the transfer-encoding header
      # The Rack::Chunked middleware will handle it 
      headers["Cache-Control"] ||= "no-cache"
      headers.delete('Content-Length')
      options[:stream] = stream
    end
  end

  def _render_template(options)
    if options.delete(:stream)
      # Just render, don't wrap in a Chunked::Body, let
      # Rack::Chunked middleware handle it
      view_renderer.render_body(view_context, options)
    else
      super
    end
  end
end

module ActionController
  class Base
    include GzipStreaming
  end
end