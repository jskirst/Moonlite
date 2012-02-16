class AddImageUrlToAchievementsTable < ActiveRecord::Migration
  def change
    add_column :achievements, :image_url, :string
  end
end
