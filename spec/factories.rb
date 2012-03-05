TASK_POINTS = 10
SEARCH_TERM = "Ruby"

Factory.define :user do |user|
	user.name					"Jonathan Dudearino"
	user.email					{ Faker::Internet.email }
	user.password				"testpassword"
	user.password_confirmation	"testpassword"
	user.association :company
	user.company_admin			"f"
end

Factory.define :company do |company|
	company.name					"Solyndra"
end

Factory.define :reward do |reward|
	reward.association :company
	reward.name Faker::Lorem.sentence(1)
	reward.description Faker::Lorem.sentence(2)
	reward.points 1000
	reward.image_url "http://www.google.com"
end

Factory.define :path do |path|
	path.name Faker::Lorem.sentence(1) + "[Ruby]"
	path.description Faker::Lorem.sentence(12)
	path.association :user
	path.is_published "t"
	path.is_public "t"
	path.is_purchaseable "t"
end

Factory.define :section do |f|
	f.name Faker::Lorem.sentence(1)
	f.instructions Faker::Lorem.sentence(2)
  f.is_published "t"
	f.association :path
end

Factory.define :task do |task|
	task.question Faker::Lorem.sentence(1)
	task.answer1 Faker::Lorem.sentence(2)
	task.answer2 Faker::Lorem.sentence(2)
	task.correct_answer 1
	task.points TASK_POINTS
	task.association :section
end

Factory.define :achievement do |f|
	f.name Faker::Lorem.sentence(1)
	f.description Faker::Lorem.sentence(2)
	f.criteria Faker::Lorem.sentence(2)
	f.points 100
	f.association :path
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

Factory.define :comment do |c|
	c.association :user
	c.association :task
	c.content Faker::Lorem.sentence(2)
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.sequence :name do |n|
	"name-#{n}"
end