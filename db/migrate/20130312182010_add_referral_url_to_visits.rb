class AddReferralUrlToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :referral_url, :text
  end
end
