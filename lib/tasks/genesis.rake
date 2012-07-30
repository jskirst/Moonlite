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
    
PATHS = [["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation...", "http://lean.st/images/startup-feedback-loop1.png?1315940898", 0],
    ["Ruby on Rails","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming...", "http://upload.wikimedia.org/wikipedia/commons/9/9c/Ruby_on_Rails_logo.jpg", 0],
]
PATH_SECTIONS = [["Introduction", "/images/default_section_pic_1.PNG"],
  ["Application", "/images/default_section_pic_2.PNG"],
  ["Advanced", "/images/default_section_pic_3.PNG"],
  ["Final test", "/images/default_section_pic_4.PNG"]]

def create_user(company,user_role,name,email,image_url)
  u = company.users.create!(:name => name, :email => email, :image_url => image_url, :password => DEFAULT_PASSWORD, :password_confirmation => DEFAULT_PASSWORD, :earned_points => 10)
  u.user_role = user_role
  u.save
  return u
end
    
namespace :db do
  desc "Fill database with production data"
  task :genesis => :environment do
    Rake::Task['db:reset'].invoke
    moonlite_company = Company.create!(:name => "Metabright")
    default_role = moonlite_company.user_roles.create!(name: "Admin", enable_administration: true, enable_user_creation: true, enable_explore: true)
    second_role = moonlite_company.user_roles.create!(name: "Test", enable_explore: true)
    moonlite_company.user_role_id = default_role.id
    moonlite_company.save
    default_cat = moonlite_company.categories.create!(:name => "Everything")
    
    moonlite_admin = create_user(moonlite_company, default_role, "Jonathan Kirst", "admin@metabright.com", "http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/220px-Kolm%C3%A5rden_Wolf.jpg")
    
    PHRASE_PAIRINGS.each do |pp|
      PhrasePairing.create_phrase_pairings(pp)
    end
      
    PATHS.each do |p|
      moonlite_company.paths.create!(:name => p[0], :description => p[1], :image_url => p[2], :user_id => moonlite_admin.id, :is_published => true, :is_public => true, :category_id => default_cat.id)
    end
    
    Path.all.each do |path|
      PATH_SECTIONS.each do |s|
        section = path.sections.create(:name => s[0], :category_id => default_cat.id, :instructions => "Instructions to follow.", :is_published => true, :image_url => s[1])
        NUMBER_OF_TASKS.times do |n|
          t = section.tasks.new(
            question: "What is #{n} + #{n}?",
            answer_content: [
              { content: "#{2*n}", is_correct: true },
              { content: "#{n-10}", is_correct: false },
              { content: "#{n-10}", is_correct: false },
              { content: "#{(4*n)+2}", is_correct: false }
            ],
            points: 10,
            answer_type: 2
          )
          t.save
        end
      end
    end
  end
end