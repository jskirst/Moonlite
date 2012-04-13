class Category < ActiveRecord::Base
	attr_accessible :company_id, :name, :category_pic, :category_pic_file_name, :category_pic_content_type, :category_pic_file_size, :category_pic_updated_at
	
	has_attached_file :category_pic,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
		:path => ":attachment/:id/:style.:extension",
		:url  => ":s3_moonlite_url",
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
	
	has_many :paths
	belongs_to :company
	
	validates :name,
	:length			=> { :within => 1..255 }
	
	before_destroy :reassign_paths
	
	private
		
		def reassign_paths
			paths.all.each do |p|
				p.category_id = -1
				p.save
			end
		end
end
