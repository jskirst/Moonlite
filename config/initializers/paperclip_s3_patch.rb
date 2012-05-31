if Rails.env.production?
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
	}
elsif Rails.env.staging?
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-staging.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
	}
elsif Rails.env.development?
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-dev.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
	}
else
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-test.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}"
	}
end