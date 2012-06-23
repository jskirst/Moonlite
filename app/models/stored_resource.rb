class StoredResource < ActiveRecord::Base
  attr_accessible :owner_id, :owner_name, :section_id, :path_id, :task_id, :description, :link, :info_type, :obj, :obj_file_name, :obj_content_type, :obj_file_size, :obj_updated_at
  
  has_attached_file :obj,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
    :path => ":attachment/:id/:style.:extension",
    :url  => ":s3_moonlite_url",
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  
  validates :owner_id,
    :presence => true
    
  validates :owner_name,
    :length => { :within => 1..40 }
  
  validates :description,
  :length      => { :maximum => 255 }

  validates :link,
  :length      => { :maximum => 255 }
end
