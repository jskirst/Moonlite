Factory.define :user do |user|
	user.name					"Test User"
	user.email					"test@testing.com"
	user.password				"testpassword"
	user.password_confirmation	"testpassword"
end

Factory.define :company do |company|
	company.name					"Test Company"
end

Factory.define :path do |path|
	path.name "Path name"
	path.description "Path description"
	path.association :user
end

Factory.define :task do |task|
	task.question "Test question"
	task.answer1 "Test answer"
	task.correct_answer 1
	task.points 5
	task.association :path
end

Factory.define :enrollment do |enrollment|
	enrollment.association :path
	enrollment.association :user
end

Factory.define :company_user do |company_user|
	company_user.email "test@test.com"
	company_user.user_id nil
	company_user.association :company
end

Factory.define :completed_task do |completed_task|
	completed_task.quiz_session DateTime.now
	completed_task.association :task
	completed_task.association :user
	completed_task.status_id 1
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.sequence :name do |n|
	"name-#{n}"
end