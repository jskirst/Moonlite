class AddAutoenrollSignuplinkCollaborationToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :enable_auto_enroll, :boolean, :default => true
		add_column :companies, :enable_collaboration, :boolean, :default => true
		add_column :companies, :enable_one_signup, :boolean, :default => true
		add_column :companies, :signup_token, :string
  end
end
