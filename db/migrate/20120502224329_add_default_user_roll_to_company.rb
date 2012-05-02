class AddDefaultUserRollToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :user_roll_id, :integer
  end
end
