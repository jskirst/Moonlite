class NotificationSettings < ActiveRecord::Base
  attr_readonly :user_id
  attr_accessible :user_id, :weekly, :powers, :interaction, :inactive
  
  validates :user_id, presence: true
  
  belongs_to :user

  def self.stats
  	stats = {}
  	users = User.where(locked_at: nil).where("email NOT LIKE ?", '%@metabright.com').joins(:notification_settings)
  	stats[:total_users] = users.count
	stats[:total_unsubscribed] = users.where("notification_settings.inactive" => true).count
	stats[:total_unsubscribed_weekly] = users.where("notification_settings.weekly" => false).count
	stats[:total_unsubscribed_powers] = users.where("notification_settings.powers" => false).count
	stats[:total_unsubscribed_interaction] = users.where("notification_settings.interaction" => false).count
	stats[:total_sent_email_today] = users.where("DATE(users.last_email_sent_at) = DATE(?)", Time.now).count
	stats[:total_maxed_out_today] = users.where("emails_today = ?", User::MAX_DAILY_EMAILS).count
	return stats
	end
end