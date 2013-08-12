class AddProfessionalAtToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :professional_at, :timestamp 
  end
end
