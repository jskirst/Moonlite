TASK_POINTS = 5
SEARCH_TERM = "Ruby"

Factory.define :user do |user|
	user.name					"Jonathan Dudearino"
	user.email					{ Faker::Internet.email }
	user.password				"testpassword"
	user.password_confirmation	"testpassword"
end

Factory.define :company do |company|
	company.name					"Solyndra"
end

Factory.define :reward do |reward|
	reward.association :company
	reward.name Faker::Lorem.sentence(5)
	reward.description Faker::Lorem.sentence(10)
	reward.points 1000
	reward.image_url "http://www.google.com"
end

Factory.define :path do |path|
	path.name Faker::Lorem.sentence(5) + "[Ruby]"
	path.description Faker::Lorem.sentence(10)
	path.association :user
end

Factory.define :task do |task|
	task.question Faker::Lorem.sentence(10)
	task.answer1 Faker::Lorem.sentence(5)
	task.correct_answer 1
	task.points TASK_POINTS
	task.association :path
end

Factory.define :enrollment do |enrollment|
	enrollment.association :path
	enrollment.association :user
end

Factory.define :info_resource do |info_resource|
	info_resource.association :path
	info_resource.description "This is a description of the resource."
	info_resource.link "http://www.testlink.com"
end

Factory.define :company_user do |company_user|
	company_user.email "test@test.com"
	company_user.user_id nil
	company_user.association :company
	company_user.is_admin "f"
end

Factory.define :completed_task do |completed_task|
	completed_task.quiz_session DateTime.now
	completed_task.association :task
	completed_task.association :user
	completed_task.status_id 1
end

Factory.define :user_transaction do |pt|
	pt.association :user
	pt.association :task
	pt.amount TASK_POINTS
	pt.status 0
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.sequence :name do |n|
	"name-#{n}"
end