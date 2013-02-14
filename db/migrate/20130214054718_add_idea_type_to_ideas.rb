class AddIdeaTypeToIdeas < ActiveRecord::Migration
  def change
    add_column :ideas, :idea_type, :integer, default: Idea::IDEA
  end
end
