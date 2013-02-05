class AddEmailsTodayToUsers < ActiveRecord::Migration
  def change
    add_column :users, :emails_today, :integer, default: 0
    add_column :users, :last_email_sent_at, :datetime
  end
end
