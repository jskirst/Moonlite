class AddUserRollToUser < ActiveRecord::Migration
  def change
		add_column :users, :user_roll_id, :integer
  end
end
