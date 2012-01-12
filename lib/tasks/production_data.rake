DEFAULT_PASSWORD = "password"
NUMBER_OF_USERS = 5
NUMBER_OF_TASKS = 30
TIME_PERIOD = 7
AVG_SCORE = 7

NAMES = ["Cave Johnson", "Carl Malone", "Mara Jade", "JC Denton", "Butch Cassidy", "Dr. Sam Beckett", "Hugo Weaving", 
		"Mr. Anderson","Gordon Freeman", "Stan Marsh", "Aeryn Sun", "Guybrush Threepwood", "Jayne Cobb", 
		"Ellen Ripley", "John Crichton", "Atticus Finch", "Dak Ralter"]

REWARDS = [["$10 iTunes Gift Card", "iTunes Gift Card worth 10 Dollars.", "http://cultofmac.cultofmaccom.netdna-cdn.com/wp-content/uploads/2011/10/itunes_giftcard.jpg", 500],
		["$20 Amazon Gift Card", "Amazon Gift Card worth 20 Dollars.", "http://news.cnet.com/i/tim/2011/01/19/Amazon_gift_card.jpg", 1000],
		["$40 Apple Store Gift Card", "Apple Store Gift Card worth 40 Dollars.", "http://images.apple.com/gift-cards/images/apple_card20100217.png", 2000],
		["2 Days of Payed-Time-Off", "You've worked pretty hard. Take a day off or two on the company.", "http://static1.itsuxtobefat.com/uploads/vacation.jpg", 3000],
		["2 Southwest Tickets", "2 Roundtrip Southwest tickets to anywhere in the U.S.", "http://www.nawbo.org/imageuploads/video_southwest.jpg", 10000],
		["2% Pay Increase", "You are a valuable and knowledgeable member of our team, so heres a little extra moula to keep you around.", "http://www.wpclipart.com/money/bag_of_money.png", 20000]]

PATHS = [["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation of rapid prototypes designed to test market assumptions, and uses customer feedback to evolve them much faster..."],
		["Ruby on Rails - Basic","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming. Powerful web applications that formerly might have taken weeks or months to develop can be produced in a matter of days."],
		["Ruby on Rails - Intermediate","I'm glad people liked the introduction to Rails; now you scallawags get to avoid my headaches with the model-view-controller (MVC) pattern. This isn't quite an intro to MVC, it's a list of gotchas as you plod through MVC the first few times."],
		["Ruby on Rails - Advanced","These pages deal with some of the more advanced concepts of Ruby and are geared toward intermediate and advanced programmers. The covered concepts will build upon the more basic features of Ruby, a discussion of which can be found in Beginning Ruby."],
		["Moonlite Feature Set","Know the Moonlite feature set from top to bottom to become and enterprise sales machine!"],
		["Salesforce CRM","Its monstrous, complex and an eyesore, but its the best CRM and sales management tool out there so we're stuck with it so we better learn how to use it."]]

def create_user(name, email, company_id, is_admin = false)
	u = User.create!(:name => name, :email => email, :password => DEFAULT_PASSWORD, :password_confirmation => DEFAULT_PASSWORD)
	CompanyUser.create!(:company_id => company_id, :email => email ,:user_id => u.id, :is_admin => is_admin)
	return u
end
		
namespace :db do
	desc "Fill database with production data"
	task :genesis => :environment do
		Rake::Task['db:reset'].invoke
		moonlite_company = Company.create!(:name => "Moonlite")
		moonlite_admin = create_user("Jonathan Kirst", "jc@moonlite.com", moonlite_company.id, true)
		moonlite_user = create_user("Nathan Sokol-Ward", "nathan@moonlite.com", moonlite_company.id, true)
		
		REWARDS.each do |r|
			moonlite_company.rewards.create!(:name => r[0], :description => r[1], :image_url => r[2], :points => r[3])
		end
			
		PATHS.each do |p|
			moonlite_admin.paths.create!(:name => p[0], :description => p[1], :company_id => moonlite_company.id)
		end
		
		Path.all.each do |path|
			NUMBER_OF_TASKS.times do |n|
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
		
		NUMBER_OF_USERS.times do |n|
			new_user = nil
			while(new_user.nil?)
				name = NAMES[rand(NAMES.size)]
				email = name.gsub(" ",".") + "@moonlite.com"
				if User.find_by_email(email).nil?
					new_user = create_user(name,email,moonlite_company.id)
				end
			end
			
			Path.all.each do |p|
				if rand(2) == 1
					new_user.enrollments.create!(:path_id => p.id)
					stop = rand(NUMBER_OF_TASKS)
					stop_counter = 0
					p.tasks.each do |t|
						if stop_counter >= stop
							break
						else
							score = rand(10)
							if score > AVG_SCORE
								status_id = 0
							else
								status_id = 1
							end
							
							date = rand(TIME_PERIOD).days.ago
							new_user.completed_tasks.create!(:task_id => t.id, :status_id => status_id, :quiz_session => date, :updated_at => date)
							new_user.award_points(t)
						end
						stop_counter += 1							
					end
				end
			end
		end
	end
end