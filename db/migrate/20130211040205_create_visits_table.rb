class CreateVisitsTable < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :user_id
      t.integer :visitor_id
      t.string  :request_url
      
      t.timestamps
    end
  end
end
