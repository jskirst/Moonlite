class AddSeatLimitToCompanies < ActiveRecord::Migration
  def change
		add_column :companies, :seat_limit, :integer, :default => 50
  end
end
