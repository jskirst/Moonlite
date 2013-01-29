class AddIsReviewedToComments < ActiveRecord::Migration
  def change
    add_column :comments, :is_reviewed, :boolean, default: false
  end
end
