class PullUidAndProviderIntoUserAuthsRow < ActiveRecord::Migration
  def change
    User.where("uid is not ?", nil).each do |u|
      unless u.user_auths.find_by_provider_and_uid(u.provider, u.uid)
        u.user_auths.create!(:provider => u.provider, :uid => u.uid)
      end
    end
  end
end
