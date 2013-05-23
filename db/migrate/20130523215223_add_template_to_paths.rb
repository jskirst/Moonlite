class AddTemplateToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :template, :text
  end
end
