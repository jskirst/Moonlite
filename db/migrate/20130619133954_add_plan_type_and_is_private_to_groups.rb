class AddPlanTypeAndIsPrivateToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :plan_type, :integer, default: 0
    add_column :groups, :is_private, :boolean, default: true
  end
end

