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
    
PERSONAS = YAML.load(File.read(File.join(Rails.root, "/lib/tasks/personas.yml")))

PATHS = [
  ["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation...", "http://lean.st/images/startup-feedback-loop1.png?1315940898", 0],
  ["Ruby on Rails","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming...", "http://upload.wikimedia.org/wikipedia/commons/9/9c/Ruby_on_Rails_logo.jpg", 0],
  ["Challenge ","Our solar system is a cool place.", "http://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Moons_of_solar_system_v7.jpg/1024px-Moons_of_solar_system_v7.jpg", 0],
  ["Pelopponesian War","Brutal stuff.", "http://upload.wikimedia.org/wikipedia/commons/a/a9/Peloponnesian_war_alliances_431_BC.png", 0]
]

PATH_SECTIONS = [
  ["Introduction", "/images/default_section_pic_1.PNG"],
  ["Application", "/images/default_section_pic_2.PNG"],
  ["Advanced", "/images/default_section_pic_3.PNG"],
  ["Final test", "/images/default_section_pic_4.PNG"]
]

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
    moonlite_company = Company.create!(:name => "MetaBright")
    default_role = moonlite_company.user_roles.create!(name: "Admin", enable_administration: true, enable_content_creation: true)
    second_role = moonlite_company.user_roles.create!(name: "Test")
    moonlite_company.user_role_id = default_role.id
    moonlite_company.save
    default_cat = moonlite_company.categories.create!(:name => "Everything")
    
    moonlite_admin = create_user(moonlite_company, default_role, "Jonathan Kirst", "admin@metabright.com", "http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/220px-Kolm%C3%A5rden_Wolf.jpg")
    
    PHRASE_PAIRINGS.each do |pp|
      PhrasePairing.create_phrase_pairings(pp)
    end
    
    unless ENV['DISABLE_FAKE']  
      PATHS.each do |p|
        moonlite_company.paths.create!(:name => p[0], :description => p[1], :image_url => p[2], :user_id => moonlite_admin.id, :is_published => true, :is_public => true, :is_approved => true, :category_id => default_cat.id)
      end
    
      Path.all.each do |path|
        PATH_SECTIONS.each do |s|
          section = path.sections.create(:name => s[0], :category_id => default_cat.id, :instructions => "Instructions to follow.", :is_published => true, :image_url => s[1])
          NUMBER_OF_TASKS.times do |n|
            section.tasks.create!(
              question: "What is #{n} + #{n}?",
              answer_content: [
                { content: "#{2*n}", is_correct: true },
                { content: "#{n-10}", is_correct: false },
                { content: "#{n-10}", is_correct: false },
                { content: "#{(4*n)+2}", is_correct: false }
              ],
              points: 10,
              answer_type: 2,
              creator_id: moonlite_admin
            )
          end
          section.tasks.create!(question: "This is a text question", answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT, creator_id: moonlite_admin)
          section.tasks.create!(question: "This is a image question", answer_type: Task::CREATIVE, answer_sub_type: Task::IMAGE, creator_id: moonlite_admin)
          section.tasks.create!(question: "This is a youtube question", answer_type: Task::CREATIVE, answer_sub_type: Task::YOUTUBE, creator_id: moonlite_admin)
        end
      end
    end
    
    criteria = Path.all.to_a.collect &:id
    PERSONAS.each do |persona|
      persona = persona[1]
      next if persona["name"].include?("lock")
      new_persona = moonlite_company.personas.create!(name: persona["name"], description: persona["description"], image_url: persona["link"], criteria: criteria)
      criteria = nil if criteria
    end
  end
end