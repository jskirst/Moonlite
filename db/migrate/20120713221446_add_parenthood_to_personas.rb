class AddParenthoodToPersonas < ActiveRecord::Migration
  def change
    add_column :personas, :parent_id, :integer
    add_column :personas, :unlock_threshold, :integer
    
    add_column :user_personas, :level, :integer
    
    add_column :enrollments, :level, :integer
  end
end
