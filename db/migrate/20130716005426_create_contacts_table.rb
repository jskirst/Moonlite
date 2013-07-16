class CreateContactsTable < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.integer :owner_id
      
      t.timestamp :purchased_at
      t.timestamp :paid_at
      t.timestamp :contacted_at
      t.timestamp :responded_at
      
      t.text :response
      t.integer :response_status, default: 0
      t.decimal :amount_paid
    end
  end
end
