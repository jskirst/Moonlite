class ChangeIsPurchaseableToIsApproved < ActiveRecord::Migration
  def change
    rename_column :paths, :is_purchaseable, :is_approved
  end
end
