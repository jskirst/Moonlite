class AddCompanyIdToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :company_id, :integer
  end
end
