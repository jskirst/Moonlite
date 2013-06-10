class ChangeHasCommentsToTotalComments < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :total_comments, :integer, default: 0
  end
end
