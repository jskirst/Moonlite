class StoredResource < ActiveRecord::Base
  attr_accessible :owner_id, 
    :owner_type,
    :description, 
    :link,
    :obj
  
  belongs_to :owner, :polymorphic => true
  
  has_attached_file :obj,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
    :path => ":attachment/:id/:style.:extension",
    :url  => ":s3_moonlite_url",
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  
  validates :description, length: { maximum: 255 }
  validates :link, length: { maximum: 255 }
end
