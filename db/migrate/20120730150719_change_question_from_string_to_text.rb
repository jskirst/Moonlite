class ChangeQuestionFromStringToText < ActiveRecord::Migration
  def change
    change_column :tasks, :question, :text
  end
end
