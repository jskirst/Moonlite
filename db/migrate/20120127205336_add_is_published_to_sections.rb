class AddIsPublishedToSections < ActiveRecord::Migration
  def change
	add_column :sections, :is_published, :boolean, :default => false
  end
end
