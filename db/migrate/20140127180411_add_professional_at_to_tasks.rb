class AddProfessionalAtToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :professional_at, :timestamp
  end
end
