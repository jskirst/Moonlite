DEFAULT_PASSWORD = "a1b2c3"
NUMBER_OF_USERS = 15
TIME_PERIOD = 7
AVG_SCORE = 9

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


def create_user(company,user_role,name,email,image_url)
	u = company.users.create!(:name => name, :email => email, :image_url => image_url, :password => DEFAULT_PASSWORD, :password_confirmation => DEFAULT_PASSWORD, :earned_points => 10)
	u.user_role_id = user_role.id
	u.save
	return u
end
		
namespace :db do
	desc "Fill database with user data"
	task :popularize => :environment do
		moonlite_company = Company.find(1)
		user_role = moonlite_company.user_role
		new_users = []
		FAKE_USERS.each do |fake_user|
			name = fake_user[0]
			email = name.gsub(" ",".") + rand(100).to_s + "@demo.moonlite.com"
			image_url = fake_user[1]
			if User.find_by_email(email).nil?
				new_users << create_user(moonlite_company, user_role, name, email, image_url)
			end
		end
		
		new_users.each do |user|
			moonlite_company.paths.where("is_published = ?", true).each do |p|
				user.enrollments.create!(:path_id => p.id)
				date = rand(TIME_PERIOD).days.ago
				p.sections.each do |s|
					s.tasks.each do |t|
						score = rand(5) + 10
						user.completed_tasks.create!(:task_id => t.id, :status_id => 1, :quiz_session => date, :points_awarded => score, :updated_at => date)
						user.award_points(t, score)
					end
				end
			end
		end
	end
end