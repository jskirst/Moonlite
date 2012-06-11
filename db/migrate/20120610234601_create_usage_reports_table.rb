class CreateUsageReportsTable < ActiveRecord::Migration
  def change
    create_table :usage_reports do |t|
      t.integer :company_id 
      t.string :name
      t.string :report_file_name
      t.string :report_content_type
      t.integer :report_file_size
      t.datetime :report_updated_at
      
      t.timestamps
    end
  end
end
