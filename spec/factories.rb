TASK_POINTS = 10
SEARCH_TERM = "Ruby"

FactoryGirl.define do
	factory :company do |company|
		company.name					"Solyndra"
	end

	factory :user_roll do |r|
		r.association :company
		r.name	"Admin"
		r.enable_administration	"t"
		r.enable_rewards	"t"
		r.enable_leaderboard	"t"
		r.enable_dashboard	"t"
		r.enable_tour	"t"
		r.enable_browsing	"t"
		r.enable_comments	"t"
		r.enable_news	"t"
		r.enable_feedback	"t"
		r.enable_achievements	"t"
		r.enable_recommendations	"t"
		r.enable_printer_friendly	"t"
		r.enable_user_creation	"t"
		r.enable_auto_enroll	"t"
		r.enable_one_signup	"t"
		r.enable_collaboration	"t"
		r.enable_auto_generate	"t"
	end

	factory :user do |user|
		user.name					"Jonathan Dudearino"
		user.email					{ Faker::Internet.email }
		user.password				"testpassword"
		user.password_confirmation	"testpassword"
		user.association :company
		user.association :user_roll
		user.company_admin			"f"
	end

	factory :reward do |reward|
		reward.association :company
		reward.name Faker::Lorem.sentence(1)
		reward.description Faker::Lorem.sentence(2)
		reward.points 1000
		reward.image_url "http://www.google.com"
	end

	factory :path do |path|
		path.name Faker::Lorem.sentence(1) + "[Ruby]"
		path.description Faker::Lorem.sentence(12)
		path.association :user
		path.association :category
		path.is_published "t"
		path.is_public "t"
		path.is_purchaseable "t"
	end

	factory :section do |f|
		f.name Faker::Lorem.sentence(1)
		f.instructions Faker::Lorem.sentence(2)
		f.is_published "t"
		f.association :path
	end

	factory :task do |task|
		task.question Faker::Lorem.sentence(1)
		task.answer1 Faker::Lorem.sentence(1)
		task.answer2 Faker::Lorem.sentence(2)
		task.answer3 Faker::Lorem.sentence(3)
		task.answer4 Faker::Lorem.sentence(4)
		task.correct_answer 1
		task.points TASK_POINTS
		task.association :section
	end

	factory :achievement do |f|
		f.name Faker::Lorem.sentence(1)
		f.description Faker::Lorem.sentence(2)
		f.criteria Faker::Lorem.sentence(2)
		f.points 100
		f.association :path
	end

	factory :enrollment do |enrollment|
		enrollment.association :path
		enrollment.association :user
	end

	factory :info_resource do |info_resource|
		info_resource.section_id	nil
		info_resource.task_id	nil
		info_resource.description "This is a description of the resource."
		info_resource.link "http://www.testlink.com"
	end

	factory :completed_task do |completed_task|
		completed_task.quiz_session DateTime.now
		completed_task.association :task
		completed_task.association :user
		completed_task.status_id 1
	end

	factory :user_transaction do |pt|
		pt.association :user
		pt.association :task
		pt.amount TASK_POINTS
		pt.status 0
	end

	factory :comment do |c|
		c.association :user
		c.association :task
		c.content Faker::Lorem.sentence(2)
	end

	factory :category do |c|
		c.association :company
		c.name Faker::Lorem.sentence(1)
	end

	sequence :email do |n|
		"person-#{n}@example.com"
	end

	sequence :name do |n|
		"name-#{n}"
	end
end