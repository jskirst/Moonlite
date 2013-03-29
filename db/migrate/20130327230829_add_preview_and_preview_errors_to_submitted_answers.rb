class AddPreviewAndPreviewErrorsToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :preview, :text
    add_column :submitted_answers, :preview_errors, :text
  end
end
