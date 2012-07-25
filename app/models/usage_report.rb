class UsageReport < ActiveRecord::Base
  attr_accessible :name, :report, :report_file_name, :report_content_type, :report_file_size, :report_updated_at, :created_at, :updated_at
  
  has_attached_file :report,
    :storage => :s3,
    :bucket => ENV['S3_BUCKET_NAME'],
    :path => ":attachment/:id/:style.:extension",
    :url  => ":s3_moonlite_url",
    :s3_credentials => {
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  
  belongs_to :company
  
  def self.generate_csv_report(report_data)
    report = CSV.open("#{Rails.root}/tmp/file.csv", "wb")
    report_data.each do |row|
      report << row
    end
    report.close
    return report
  end
  
  validates :name, length: { within: 1..255 }
end
