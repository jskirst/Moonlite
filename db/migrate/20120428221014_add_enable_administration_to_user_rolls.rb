class AddEnableAdministrationToUserRolls < ActiveRecord::Migration
  def change
		add_column :user_rolls, :enable_administration, :boolean, :default => false
  end
end
