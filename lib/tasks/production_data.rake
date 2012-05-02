DEFAULT_PASSWORD = "a1b2c3"
NUMBER_OF_USERS = 3
NUMBER_OF_TASKS = 5
TIME_PERIOD = 7
AVG_SCORE = 9

PHRASE_PAIRINGS = [
["vitamin a", "vitamin b2", "vitamin b6", "vitamin b12", "vitamin E", "vitamin k"],
["Fry", "leela", "bender", "professor farnsworth", "doctor zoidberg", "amy wong", "hermes conrad", "lord nibbler", "zapp brannigan", "kif kroker", "calculon", "clamps", "elzar"]
]

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

PATHS = [["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation...", "http://lean.st/images/startup-feedback-loop1.png?1315940898", 0],
		["Ruby on Rails","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming...", "http://upload.wikimedia.org/wikipedia/commons/9/9c/Ruby_on_Rails_logo.jpg", 0],
]
PATH_SECTIONS = [["Introduction", "/images/default_section_pic_1.PNG"],
  ["Application", "/images/default_section_pic_2.PNG"],
  ["Advanced", "/images/default_section_pic_3.PNG"],
  ["Final test", "/images/default_section_pic_4.PNG"]]

def create_user(company,user_roll,name,email,image_url)
	u = company.users.create!(:name => name, :email => email, :image_url => image_url, :password => DEFAULT_PASSWORD, :password_confirmation => DEFAULT_PASSWORD, :earned_points => 10)
	u.user_roll = user_roll
	u.save
	return u
end
		
namespace :db do
	desc "Fill database with production data"
	task :genesis => :environment do
		Rake::Task['db:reset'].invoke
		moonlite_company = Company.create!(:name => "Moonlite")
		default_roll = moonlite_company.user_rolls.create!(:name => "Admin")
		default_cat = moonlite_company.categories.create!(:name => "Everything", :enable_administration => true)
		moonlite_admin = create_user(moonlite_company, default_roll, "Jonathan Kirst", "jc@moonlite.com", "http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/220px-Kolm%C3%A5rden_Wolf.jpg")
		create_user(moonlite_company, default_roll, "Nathan Sokol-Ward", "nathan@moonlite.com", "http://www.hecticgourmet.com/blog/wp-content/uploads/2011/11/slap-chop.jpg")
		create_user(moonlite_company, default_roll, "Martha Elster", "mjelster@moonlite.com", "http://www.eskie.net/superior/west/images/jane_2c.jpg")
		create_user(moonlite_company, default_roll, "Guest User", "guest@moonlite.com", "http://rlv.zcache.com/question_mark_hat-p148553218496209654z8nb8_400.jpg")
		
    PHRASE_PAIRINGS.each do |pp|
      PhrasePairing.create_phrase_pairings(pp)
    end
    
		REWARDS.each do |r|
			moonlite_company.rewards.create!(:name => r[0], :description => r[1], :image_url => r[2], :points => r[3])
		end
			
		PATHS.each do |p|
			moonlite_admin.paths.create!(:name => p[0], :description => p[1], :image_url => p[2], :company_id => moonlite_company.id, :is_published => true, :is_public => true, :category_id => default_cat.id)
		end
		
		Path.all.each do |path|
			PATH_SECTIONS.each do |s|
				section = path.sections.create(:name => s[0], :category_id => default_cat.id, :instructions => "Instructions to follow.", :is_published => true, :image_url => s[1])
				NUMBER_OF_TASKS.times do |n|
					t = section.tasks.new(:question => "What is #{n} + #{n}?",
						:answer1 => "#{2*n}",
						:answer2 => "#{n-10}",
						:answer3 => "#{(3*n)+1}",
						:answer4 => "#{(4*n)+2}",
						:correct_answer => 1,
						:points => 10
					)
          t.save
				end
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
					new_user = create_user(moonlite_company, default_roll, name, email, image_url)
				end
			end
			
			Path.all.each do |p|
				if rand(2) == 1
					new_user.enrollments.create!(:path_id => p.id)
					stop = rand(NUMBER_OF_TASKS*PATH_SECTIONS.size)
					stop_counter = 0
					
					p.sections.each do |s|
						s.tasks.each do |t|
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
									new_user.award_points(t, 10)
								end						
							end
							stop_counter += 1							
						end
					end
				end
			end
		end
	end
end