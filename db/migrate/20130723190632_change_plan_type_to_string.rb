class ChangePlanTypeToString < ActiveRecord::Migration
  def up
    change_column :groups, :plan_type, :string
  end

  def down
    change_column :groups, :plan_type, :integer
  end
end
