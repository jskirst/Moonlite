class MoveEnableAdministrationOverToUser < ActiveRecord::Migration
  def change
    add_column :users, :enable_administration, :boolean, default: false
    
    User.find_each do |u|
      u.flush_cache
    end
  end
end
