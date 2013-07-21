class AddStripeTokenToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :stripe_token, :string
  end
end
