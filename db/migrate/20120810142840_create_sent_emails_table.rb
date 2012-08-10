class CreateSentEmailsTable < ActiveRecord::Migration
  def change
    create_table :sent_emails do |t|
      t.text  :content
      t.integer :user_id
      t.timestamps
    end
  end
end
