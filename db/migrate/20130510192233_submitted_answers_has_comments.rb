class SubmittedAnswersHasComments < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :has_comments, :boolean, default: false
  end
end
