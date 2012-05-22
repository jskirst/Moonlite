class InfoResource < ActiveRecord::Base
  attr_accessible :path_id, :section_id, :task_id, :description, :link, :info_type, :obj, :obj_file_name, :obj_content_type, :obj_file_size, :obj_updated_at
  
  has_attached_file :obj,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
    :path => ":attachment/:id/:style.:extension",
    :url  => ":s3_moonlite_url",
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  
  belongs_to :path
  belongs_to :section
  belongs_to :task
  
  validates :description,
  :length      => { :maximum => 255 }

  validates :link,
  :length      => { :maximum => 255 }

  validate :has_path_or_section_or_task
    
  private
    def has_path_or_section_or_task
      error = "Info resource requires one of the following: Path, Section or Task."
      if path.nil? && section.nil? && task.nil?
        errors[:base] << error
      elsif !path.nil? && !(section.nil? && task.nil?)
        errors[:base] << error
      elsif !section.nil? && !(path.nil? && task.nil?)
        errors[:base] << error
      elsif !task.nil? && !(path.nil? && section.nil?)
        errors[:base] << error
      end
    end
end
