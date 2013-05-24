class AddPromotedAtToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :promoted_at, :timestamp
  end
end
