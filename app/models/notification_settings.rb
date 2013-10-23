class NotificationSettings < ActiveRecord::Base
  attr_readonly :user_id
  attr_accessible :user_id, :weekly, :powers, :interaction, :inactive
  
  validates :user_id, presence: true
  
  belongs_to :user

  def self.stats
  	stats = {}
  	stats[:total_users] = User.count
		stats[:total_unsubscribed] = User.joins(:notification_settings).where("notification_settings.inactive" => true).count
		stats[:total_unsubscribed_weekly] = User.joins(:notification_settings).where("notification_settings.weekly" => false).count
		stats[:total_unsubscribed_powers] = User.joins(:notification_settings).where("notification_settings.powers" => false).count
		stats[:total_unsubscribed_interaction] = User.joins(:notification_settings).where("notification_settings.interaction" => false).count
		stats[:total_sent_email_today] = User.where("DATE(users.last_email_sent_at) = DATE(?)", Time.now).count
		stats[:total_maxed_out_today] = User.where("emails_today = ?", User::MAX_DAILY_EMAILS).count
		return stats
	end
end