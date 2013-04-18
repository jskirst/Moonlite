class AddDetailsToUserRecordForEmployers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :seen_opportunities, :boolean, default: false
    add_column :users, :wants_full_time, :boolean, default: false
    add_column :users, :wants_part_time, :boolean, default: false
    add_column :users, :wants_internship, :boolean, default: false
    add_column :users, :wants_university, :boolean, default: false
  end
end
