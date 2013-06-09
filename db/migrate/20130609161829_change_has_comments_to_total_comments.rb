class ChangeHasCommentsToTotalComments < ActiveRecord::Migration
  def change
    add_column :submitted_answers, :total_comments, :integer, default: 0

    SubmittedAnswer.all.each do |sa|
      sa.total_comments = sa.comments.count
      sa.save
    end 
  end
end
