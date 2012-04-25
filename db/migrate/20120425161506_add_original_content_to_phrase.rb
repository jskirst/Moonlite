class AddOriginalContentToPhrase < ActiveRecord::Migration
  def change
		add_column :phrases, :original_content, :string
  end
end
