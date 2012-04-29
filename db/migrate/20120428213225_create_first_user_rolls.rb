class CreateFirstUserRolls < ActiveRecord::Migration
 def change
		admin_roll = {
			:name => "Admin",
			:enable_rewards => false,
			:enable_leaderboard => true,
			:enable_dashboard => true,
			:enable_tour => false,
			:enable_browsing => true,
			:enable_comments => false,
			:enable_news => true,
			:enable_feedback => false,
			:enable_achievements => false,
			:enable_recommendations => false,
			:enable_printer_friendly => false,
			:enable_user_creation => true,
			:enable_auto_enroll => false,
			:enable_one_signup => false,
			:enable_collaboration => true,
			:enable_auto_generate => true
		}
		
		default_roll = {
			:name => "Default",
			:enable_rewards => false,
			:enable_leaderboard => true,
			:enable_dashboard => false,
			:enable_tour => false,
			:enable_browsing => true,
			:enable_comments => false,
			:enable_news => true,
			:enable_feedback => false,
			:enable_achievements => false,
			:enable_recommendations => false,
			:enable_printer_friendly => false,
			:enable_user_creation => false,
			:enable_auto_enroll => false,
			:enable_one_signup => false,
			:enable_collaboration => false,
			:enable_auto_generate => false
		}
	
		Company.all.each do |c|
			admin = c.user_rolls.create!(admin_roll)
			default = c.user_rolls.create!(default_roll)
			
			c.users.each do |u|
				if u.company_admin?
					u.user_roll_id = admin.id
				else
					u.user_roll_id = default.id
				end
				u.save
			end
		end
	end
end
