class AddUrlToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :url, :text
  end
end
