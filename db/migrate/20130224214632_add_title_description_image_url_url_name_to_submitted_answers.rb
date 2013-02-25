class AddTitleDescriptionImageUrlUrlNameToSubmittedAnswers < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :title, :text
    add_column :submitted_answers, :description, :text
    add_column :submitted_answers, :image_url, :text
    add_column :submitted_answers, :site_name, :text
  end
end
