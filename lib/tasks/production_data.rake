DEFAULT_PASSWORD = "password"
NUMBER_OF_USERS = 7
NUMBER_OF_TASKS = 30
TIME_PERIOD = 7
AVG_SCORE = 7

ACHIEVEMENTS = [["Top Gun","Correctly answer 20 questions in a row.",300],
	["Straight Shooter","Correctly answer the hardest question for the path.",25],
	["88 MPH","Correctly answering 6 questions in under a minute.", 50],
	["Revenge of the Nerds","Correctly answering all the architecture scalability questions.", 200],
	["You always remember your first","Finishing your first path.", 150],
	["That'll do pig","Getting 10 answers correct in a row.", 100]]

FAKE_USERS = [["Cave Johnson","http://www.holyduffgaming.se/filarkiv/webbprojekt/anton/CaveJohnson/CaveJohnson50.png"], 
		["Carl Malone","http://uvtblog.com/wp-content/uploads/2009/07/stocktonmalone.jpg"], 
		["Mara Jade","http://fc07.deviantart.net/fs50/f/2009/270/6/c/Mara_Jade_Skywalker_by_wraithdt.jpg"], 
		["JC Denton", "http://fc02.deviantart.net/fs15/f/2007/076/7/d/JC_Denton_by_egoyette.png"],
		["Butch Cassidy", "http://i.telegraph.co.uk/multimedia/archive/01202/butch-cassidy-paul_1202903c.jpg"],
		["Dr. Sam Beckett","http://www.tvacres.com/images/bakula_pig.jpg"],
		["Hugo Weaving","http://iblackedout.com/wp-content/uploads/2010/02/2003_the_matrix_revolution_002.jpg"], 
		["Mr. Anderson","http://www.volacci.com/files/imce-uploads/Logical%20Neo.jpg"],
		["Gordon Freeman","http://www.examiner.com/images/blog/EXID5839/images/freeman.jpg"],
		["Stan Marsh","http://images2.wikia.nocookie.net/__cb20110531150955/stanny/images/2/23/Stan_Marsh.jpg"],
		["Aeryn Sun","http://images.wikia.com/farscape/images/f/fa/John_aeryn.jpg"],
		["Guybrush Threepwood","http://upload.wikimedia.org/wikipedia/en/thumb/5/5f/Guybrush_Threepwood.png/240px-Guybrush_Threepwood.png"],
		["Jayne Cobb","http://www.orangellous.com/cdn/photos/2009/01/20090123_jayneorig2.jpg"],
		["Ellen Ripley","http://1.bp.blogspot.com/_Ne5Lb2SiFHg/TL8dO16QdjI/AAAAAAAA3XU/rXLB9LlLrB0/s1600/ellen+ripley.jpg"],
		["John Crichton","http://images.wikia.com/farscape/images/f/fa/John_aeryn.jpg"],
		["Atticus Finch","http://i699.photobucket.com/albums/vv354/Jude714/Gregory-Peck-as-Atticus-Finch.jpg"],
		["Dak Ralter","http://porkins.home.insightbb.com/Rebel/Pilots/DakRalter.jpg"]]

REWARDS = [["$10 iTunes Gift Card", "iTunes Gift Card worth 10 Dollars.", "http://cultofmac.cultofmaccom.netdna-cdn.com/wp-content/uploads/2011/10/itunes_giftcard.jpg", 500],
		["$20 Amazon Gift Card", "Amazon Gift Card worth 20 Dollars.", "http://news.cnet.com/i/tim/2011/01/19/Amazon_gift_card.jpg", 1000],
		["$40 Apple Store Gift Card", "Apple Store Gift Card worth 40 Dollars.", "http://images.apple.com/gift-cards/images/apple_card20100217.png", 2000],
		["2 Days of Paid-Time-Off", "You've worked pretty hard. Take a day off or two on the company.", "http://static1.itsuxtobefat.com/uploads/vacation.jpg", 3000],
		["2 Southwest Tickets", "2 Roundtrip Southwest tickets to anywhere in the U.S.", "http://www.nawbo.org/imageuploads/video_southwest.jpg", 10000],
		["2% Pay Increase", "You are a valuable and knowledgeable member of our team, so heres a little extra moula to keep you around.", "http://www.wpclipart.com/money/bag_of_money.png", 20000]]

PATHS = [["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation of rapid prototypes designed to test market assumptions, and uses customer feedback to evolve them much faster...", "http://lean.st/images/startup-feedback-loop1.png?1315940898"],
		["Ruby on Rails - Basic","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming. Powerful web applications that formerly might have taken weeks or months to develop can be produced in a matter of days.", "http://www.codeweek.pk/wp-content/uploads/2011/07/ruby_on_rails_logo.jpg"],
		["Ruby on Rails - Intermediate","I'm glad people liked the introduction to Rails; now you scallawags get to avoid my headaches with the model-view-controller (MVC) pattern. This isn't quite an intro to MVC, it's a list of gotchas as you plod through MVC the first few times.", "http://www.codeweek.pk/wp-content/uploads/2011/07/ruby_on_rails_logo.jpg"],
		["Ruby on Rails - Advanced","These pages deal with some of the more advanced concepts of Ruby and are geared toward intermediate and advanced programmers. The covered concepts will build upon the more basic features of Ruby, a discussion of which can be found in Beginning Ruby.", "http://www.codeweek.pk/wp-content/uploads/2011/07/ruby_on_rails_logo.jpg"],
		["Moonlite Feature Set","Know the Moonlite feature set from top to bottom to become and enterprise sales machine!", "/images/logo.png"],
		["Salesforce CRM","Its monstrous, complex and an eyesore, but its the best CRM and sales management tool out there so we're stuck with it so we better learn how to use it.", "http://www.crunchbase.com/assets/images/resized/0001/1691/11691v3-max-250x250.png"]]

def create_user(name, email,image_url,company_id, is_admin = false)
	u = User.create!(:name => name, :email => email, :image_url => image_url, :password => DEFAULT_PASSWORD, :password_confirmation => DEFAULT_PASSWORD)
	CompanyUser.create!(:company_id => company_id, :email => email ,:user_id => u.id, :is_admin => is_admin)
	return u
end
		
namespace :db do
	desc "Fill database with production data"
	task :genesis => :environment do
		Rake::Task['db:reset'].invoke
		moonlite_company = Company.create!(:name => "Moonlite")
		moonlite_admin = create_user("Jonathan Kirst", "jc@moonlite.com", "http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/220px-Kolm%C3%A5rden_Wolf.jpg", moonlite_company.id, true)
		create_user("Nathan Sokol-Ward", "nathan@moonlite.com", "http://www.hecticgourmet.com/blog/wp-content/uploads/2011/11/slap-chop.jpg", moonlite_company.id, true)
		create_user("Martha Elster", "mjelster@moonlite.com", "http://www.eskie.net/superior/west/images/jane_2c.jpg", moonlite_company.id, true)
		moonlite_admin.toggle!(:admin)
		
		REWARDS.each do |r|
			moonlite_company.rewards.create!(:name => r[0], :description => r[1], :image_url => r[2], :points => r[3])
		end
			
		PATHS.each do |p|
			moonlite_admin.paths.create!(:name => p[0], :description => p[1], :image_url => p[2], :company_id => moonlite_company.id)
		end
		
		PATHS.each do |p|
			moonlite_admin.paths.create!(:name => p[0], :description => p[1], :image_url => p[2], :is_public => true)
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
			
			ACHIEVEMENTS.each do |a|
				path.achievements.create!(:name => a[0], :description => a[1], :criteria => "Blah", :points => a[2])
			end
		end
		
		NUMBER_OF_USERS.times do |n|
			new_user = nil
			while(new_user.nil?)
				fake_user = FAKE_USERS[rand(FAKE_USERS.size)]
				name = fake_user[0]
				email = name.gsub(" ",".") + "@moonlite.com"
				image_url = fake_user[1]
				if User.find_by_email(email).nil?
					new_user = create_user(name,email,image_url,moonlite_company.id,)
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
							date = rand(TIME_PERIOD).days.ago
							score = rand(10)
							if score > AVG_SCORE
								status_id = 0
								new_user.completed_tasks.create!(:task_id => t.id, :status_id => status_id, :quiz_session => date, :updated_at => date)
							else
								status_id = 1
								new_user.completed_tasks.create!(:task_id => t.id, :status_id => status_id, :quiz_session => date, :updated_at => date)
								new_user.award_points(t)
							end
							
							if rand(6) == 1
								achievement = p.achievements.first
								new_user.user_achievements.create!(:achievement_id => achievement.id, :updated_at => date)
							end							
						end
						stop_counter += 1							
					end
				end
			end
		end
	end
end