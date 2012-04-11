class AddHiddenContentToSection < ActiveRecord::Migration
  def change
    add_column :sections, :hidden_content, :text
  end
end
