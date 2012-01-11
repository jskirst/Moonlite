ITUNES_IMAGE = "http://cultofmac.cultofmaccom.netdna-cdn.com/wp-content/uploads/2011/10/itunes_giftcard.jpg"
AMAZON_IMAGE = "http://news.cnet.com/i/tim/2011/01/19/Amazon_gift_card.jpg"
APPLE_IMAGE = "http://images.apple.com/gift-cards/images/apple_card20100217.png"
PTO_IMAGE = "http://static1.itsuxtobefat.com/uploads/vacation.jpg"
SOUTHWEST_IMAGE = "http://www.nawbo.org/imageuploads/video_southwest.jpg"
PAY_IMAGE = "http://www.wpclipart.com/money/bag_of_money.png"


if !Rails.env.production?
	require 'faker'

	namespace :db do
		desc "Fill database with sample data"
		task :populate => :environment do
			Rake::Task['db:reset'].invoke
			moonlite_company = Company.create!(:name => "Moonlite")
			moonlite_company.rewards.create!(:name => "$10 iTunes Gift Card", :description => "iTunes Gift Card worth 10 Dollars.", :image_url => ITUNES_IMAGE, :points => 500)
			moonlite_company.rewards.create!(:name => "$20 Amazon Gift Card", :description => "Amazon Gift Card worth 20 Dollars.", :image_url => AMAZON_IMAGE, :points => 1000)
			moonlite_company.rewards.create!(:name => "$40 Apple Store Gift Card", :description => "Apple Store Gift Card worth 40 Dollars.", :image_url => APPLE_IMAGE, :points => 2000)
			moonlite_company.rewards.create!(:name => "2 Days of Payed-Time-Off", :description => "You've worked pretty hard. Take a day off or two on the company.", :image_url => PTO_IMAGE, :points => 3000)
			moonlite_company.rewards.create!(:name => "2 Southwest Tickets", :description => "2 Roundtrip Southwest tickets to anywhere in the U.S.", :image_url => SOUTHWEST_IMAGE, :points => 10000)
			moonlite_company.rewards.create!(:name => "2% Pay Increase", :description => "You are a valuable and knowledgeable member of our team, so heres a little extra moula to keep you around.", :image_url => PAY_IMAGE, :points => 20000)
			moonlite_admin = User.create!(:name => "Jonathan Kirst",
				:email => "admin@moonlite.com",
				:password => "password",
				:password_confirmation => "password")
			moonlite_admin.toggle!(:admin)
			CompanyUser.create!(:company_id => moonlite_company.id,
				:email => moonlite_admin.email,
				:user_id => moonlite_admin.id,
				:is_admin => true)
			moonlite_user = User.create!(:name => "Nathan Sokol-Ward",
				:email => "user@moonlite.com",
				:password => "password",
				:password_confirmation => "password")
			CompanyUser.create!(:company_id => moonlite_company.id,
				:email => moonlite_user.email,
				:user_id => moonlite_user.id,
				:is_admin => false)
				
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "LEAN Startup Methodology", :description => description, :company_id => moonlite_company.id)
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "Ruby on Rails - Basic", :description => description, :company_id => moonlite_company.id)
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "Ruby on Rails - Intermediate", :description => description, :company_id => moonlite_company.id)
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "Ruby on Rails - Advanced", :description => description, :company_id => moonlite_company.id)
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "Moonlite Feature Set", :description => description, :company_id => moonlite_company.id)
			description = Faker::Lorem.sentence(20)
			moonlite_admin.paths.create!(:name => "Salesforce CRM", :description => description, :company_id => moonlite_company.id)
			
			
			Path.all(:limit => 10).each do |path|
				30.times do |n|
					path.tasks.create!(:question => "What is #{n} + #{n}?",
						:answer1 => "#{n-10}",
						:answer2 => "#{2*n}",
						:answer3 => "#{(3*n)+1}",
						:answer4 => "#{(4*n)+2}",
						:correct_answer => 2,
						:points => 10
					)
				end
			end
				
			5.times do |n|
				name = Faker::Name.name
				email = "example#{n+1}@moonlite.com"
				password = "password"
				u = User.create!(:name => name,
					:email => email,
					:password => password,
					:password_confirmation => password)
				CompanyUser.create!(:company_id => moonlite_company.id,
					:email => u.email,
					:user_id => u.id,
					:is_admin => false)
				
				rand(8).times do |n|
					id = rand(7)
					path = Path.find_by_id(id)
					if !path.nil? && !u.enrolled?(path)
						u.enrollments.create!(:path_id => path.id)
						stop = rand(30)
						stop_counter = 0
						path.tasks.each do |t|
							if stop_counter >= stop
								break
							else
								score = rand(10)
								if score > 8
									status_id = 0
								else
									status_id = 1
								end
								
								date = rand(7).days.ago
								u.completed_tasks.create!(:task_id => t.id, :status_id => status_id, :quiz_session => date, :updated_at => date)
								u.award_points(t)
							end
							stop_counter += 1							
						end
					end
				end
			end
			
			# large_company = Company.create!(:name => "Cisco")
			# large_company.rewards.create!(:name => "$10 iTunes Gift Card", :description => "iTunes Gift Card worth 10 Dollars.", :image_url => "http://www.google.com", :points => 500)
			# large_company.rewards.create!(:name => "$20 Amazon Gift Card", :description => "Amazon Gift Card worth 20 Dollars.", :image_url => "http://www.google.com", :points => 1000)
			# large_company.rewards.create!(:name => "$40 Apple Store Gift Card", :description => "Apple Store Gift Card worth 40 Dollars.", :image_url => "http://www.google.com", :points => 2000)
			# large_company.rewards.create!(:name => "1 Day of Payed-Time-Off", :description => "You've worked pretty hard. Take a day off on the company.", :image_url => "http://www.google.com", :points => 3000)
			# large_company.rewards.create!(:name => "2 Southwest Tickets", :description => "2 Roundtrip Southwest tickets to anywhere in the U.S.", :image_url => "http://www.google.com", :points => 10000)				
			# large_company_admin = User.create!(:name => "Admin User",
				# :email => "admin@cisco.com",
				# :password => "password",
				# :password_confirmation => "password")
			# CompanyUser.create!(:company_id => large_company.id,
				# :email => large_company_admin.email,
				# :user_id => large_company_admin.id,
				# :is_admin => true)
			# 99.times do |n|
				# name = Faker::Name.name
				# email = "example#{n+1}@example.com"
				# password = "password"
				# u = User.create!(:name => name,
					# :email => email,
					# :password => password,
					# :password_confirmation => password)
				# CompanyUser.create!(:company_id => large_company.id,
				# :email => u.email,
				# :user_id => u.id,
				# :is_admin => false)
			# end
			# 5.times do |n|
				# name = Faker::Lorem.sentence(3)
				# description = Faker::Lorem.sentence(20)
				# large_company_admin.paths.create!(:name => name, :description => description, :company_id => large_company_admin.id)
			# end
			# Path.all(:limit => 10).each do |path|
				# 15.times do |n|
					# path.tasks.create!(:question => "What is #{n} + #{n}?",
						# :answer1 => "#{1*n}",
						# :answer2 => "#{2*n}",
						# :answer3 => "#{3*n}",
						# :answer4 => "#{4*n}",
						# :correct_answer => 2,
						# :points => 10
					# )
				# end
			# end
		end
	end
end