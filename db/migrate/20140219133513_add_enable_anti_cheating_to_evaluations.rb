class AddEnableAntiCheatingToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :enable_anti_cheating, :boolean, default: false
  end
end
