Factory.define :user do |user|
	user.name					"Test User"
	user.email					"test@testing.com"
	user.password				"testpassword"
	user.password_confirmation	"testpassword"
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.define :micropost do |micropost|
	micropost.content "Foo bar"
	micropost.association :user
end