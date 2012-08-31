class ChangeContentToText < ActiveRecord::Migration
  def change
    change_column :submitted_answers, :content, :text
  end
end
