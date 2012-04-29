class CreateUserRolesTable < ActiveRecord::Migration
  def change
		create_table :user_rolls do |t|
			t.string :name
			t.integer :company_id
			t.boolean  "enable_leaderboard",           :default => false
			t.boolean  "enable_dashboard",             :default => false
			t.boolean  "enable_tour",                  :default => false
			t.boolean  "enable_comments",              :default => false
			t.boolean  "enable_feedback",              :default => false
			t.boolean  "enable_news",                  :default => false
			t.boolean  "enable_achievements",          :default => false
			t.boolean  "enable_recommendations",       :default => false
			t.boolean  "enable_printer_friendly",      :default => false
			t.boolean  "enable_browsing",              :default => false
			t.boolean  "enable_user_creation",         :default => false
			t.boolean  "enable_auto_enroll",           :default => false
			t.boolean  "enable_collaboration",         :default => false
			t.boolean  "enable_one_signup",            :default => false
			t.boolean  "enable_company_store",         :default => false
			t.boolean  "enable_auto_generate",         :default => false
			t.string   "signup_token"
			t.timestamps
		end
  end
end
