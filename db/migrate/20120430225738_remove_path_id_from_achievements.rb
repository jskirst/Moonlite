class RemovePathIdFromAchievements < ActiveRecord::Migration
	def change
		remove_column :achievements, :path_id
	end
end
