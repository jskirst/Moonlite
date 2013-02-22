class AddCaptionToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :caption, :text
  end
end
