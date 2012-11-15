class AddReviewedToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :is_reviewed, :boolean, default: false
  end
end
