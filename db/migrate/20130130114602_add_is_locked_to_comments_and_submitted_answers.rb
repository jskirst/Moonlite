class AddIsLockedToCommentsAndSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :comments, :is_locked, :boolean, default: false
    add_column :submitted_answers, :is_locked, :boolean, default: false
  end
end
