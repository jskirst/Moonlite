Factory.define :user do |user|
	user.name					"Test User"
	user.email					"test@testing.com"
	user.password				"testpassword"
	user.password_confirmation	"testpassword"
end

Factory.define :path do |path|
	path.name "Path name"
	path.description "Path description"
	path.association :user
end

Factory.define :task do |task|
	task.question "Question"
	task.answer "Answer"
	task.rank 1
	task.association :path
end

Factory.define :enrollment do |enrollment|
	enrollment.association :path
	enrollment.association :user
end

Factory.define :completed_task do |completed_task|
	completed_task.association :task
	completed_task.association :user
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end