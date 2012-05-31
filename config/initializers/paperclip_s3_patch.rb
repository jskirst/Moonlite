current_env = ENV['RACK_ENV'] || Rails.env

if current_env == "production"
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}".gsub("::",":")
	}
elsif current_env == "staging"
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-staging.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}".gsub("::",":")
	}
elsif current_env == "development"
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-dev.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}".gsub("::",":")
	}
else
	Paperclip.interpolates(:s3_moonlite_url) { |attachment, style|
		"#{attachment.s3_protocol}://moonlite-test.s3.amazonaws.com/#{attachment.path(style).gsub(%r{^/}, "")}".gsub("::",":")
	}
end