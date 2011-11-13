require 'faker'

namespace :db do
	desc "Fill database with sample data"
	task :populate => :environment do
		Rake::Task['db:reset'].invoke
		admin = User.create!(:name => "Example User",
			:email => "admin@pm.com",
			:password => "password",
			:password_confirmation => "password")
		admin.toggle!(:admin)
		99.times do |n|
			name = Faker::Name.name
			email = "example#{n+1}@example.com"
			password = "password"
			User.create!(:name => name,
				:email => email,
				:password => password,
				:password_confirmation => password)
		end
		5.times do |n|
			name = Faker::Lorem.sentence(3)
			description = Faker::Lorem.sentence(20)
			admin.paths.create!(:name => name, :description => description)
		end
		Path.all(:limit => 10).each do |path|
			15.times do |n|
				path.tasks.create!(:question => "What is #{n} + #{n}?",
					:answer1 => "#{1*n}",
					:answer2 => "#{2*n}",
					:answer3 => "#{3*n}",
					:answer4 => "#{4*n}",
					:correct_answer => 2,
					:points => 10
				)
			end
		end
	end
end