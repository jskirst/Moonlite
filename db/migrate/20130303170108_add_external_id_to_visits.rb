class AddExternalIdToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :external_id, :string
    
    add_index :visits, :external_id, unique: true
    
    Visit.all.each { |v| v.update_attribute(:external_id, SecureRandom.hex(16)) }
  end
end
