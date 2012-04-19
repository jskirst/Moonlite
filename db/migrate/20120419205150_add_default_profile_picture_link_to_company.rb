class AddDefaultProfilePictureLinkToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :default_profile_picture_link, :string
  end
end
