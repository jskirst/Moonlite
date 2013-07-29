DEFAULT_PASSWORD = "a1b2c3"
NUMBER_OF_USERS = 3
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
  ["LEAN Startup Methodology 2","Lean startup is a term coined by Eric Ries, his method advocates the creation...", "http://lean.st/images/startup-feedback-loop1.png?1315940898", 0],
  ["Ruby on Rails 2","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming...", "http://upload.wikimedia.org/wikipedia/commons/9/9c/Ruby_on_Rails_logo.jpg", 0],
  ["Heroku 2","Our solar system is a cool place.", "http://moonlite.s3.amazonaws.com/objs/71/original.png?1354912232", 0],
  ["jQuery 2","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/68/original.png?1354911643", 0],
  ["HTML5 2","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/143/original.png?1362693305", 0],
  ["CSS 2","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/132/original.jpg?1361987588", 0],
  ["Ruby Without Rails2 ","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/115/original.png?1359821271", 0],
  ["RubyGems 2","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/74/original.png?1354916814", 0],
  ["LEAN Startup Methodology","Lean startup is a term coined by Eric Ries, his method advocates the creation...", "http://lean.st/images/startup-feedback-loop1.png?1315940898", 0],
  ["Ruby on Rails","Ruby on Rails is a breakthrough in lowering the barriers of entry to programming...", "http://upload.wikimedia.org/wikipedia/commons/9/9c/Ruby_on_Rails_logo.jpg", 0],
  ["Heroku","Our solar system is a cool place.", "http://moonlite.s3.amazonaws.com/objs/71/original.png?1354912232", 0],
  ["jQuery","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/68/original.png?1354911643", 0],
  ["HTML5","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/143/original.png?1362693305", 0],
  ["CSS","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/132/original.jpg?1361987588", 0],
  ["Ruby Without Rails","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/115/original.png?1359821271", 0],
  ["RubyGems","Brutal stuff.", "http://moonlite.s3.amazonaws.com/objs/74/original.png?1354916814", 0]
]

PATH_SECTIONS = [
  ["Introduction", "/images/default_section_pic_1.PNG"],
  ["Application", "/images/default_section_pic_2.PNG"],
  ["Advanced", "/images/default_section_pic_3.PNG"],
  ["Final test", "/images/default_section_pic_4.PNG"]
]

def create_user(company,user_role,name,email,image_url)
  u = company.users.new(name: name, 
    email: email, 
    image_url: image_url, 
    password: DEFAULT_PASSWORD, 
    password_confirmation: DEFAULT_PASSWORD, 
    earned_points: 10)
  u.grant_username
  u.user_role = user_role
  u.save!
  return u
end
    
namespace :db do
  desc "Fill database with production data"
  task :genesis => :environment do
    raise "FATAL: CANNOT RUN SCRIPT OUTSIDE DEVELOPMENT" unless Rails.env == "development"
    Rake::Task['db:reset'].invoke
    moonlite_company = Company.create!(:name => "MetaBright")
    default_role = moonlite_company.user_roles.create!(name: "Admin", enable_administration: true, enable_content_creation: true)
    second_role = moonlite_company.user_roles.create!(name: "Test")
    moonlite_company.user_role_id = default_role.id
    moonlite_company.save!
    default_cat = moonlite_company.categories.create!(:name => "Everything")
    
    moonlite_admin = create_user(moonlite_company, default_role, "Jonathan Kirst", "admin@metabright.com", "http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kolm%C3%A5rden_Wolf.jpg/220px-Kolm%C3%A5rden_Wolf.jpg")
    raise "Failed to create user" unless moonlite_admin.valid?
    PHRASE_PAIRINGS.each do |pp|
      PhrasePairing.create_phrase_pairings(pp)
    end
     
    now = Time.now
    PERSONAS.each do |persona|
      persona = persona[1]
      new_persona = moonlite_company.personas.create!(name: persona["name"], description: persona["description"], image_url: persona["link"])
    end
    
    PATHS.each do |p|
      path = moonlite_company.paths.create!(name: p[0], description: p[1], image_url: p[2], user_id: moonlite_admin.id, category_id: default_cat.id)
      path.published_at = now
      path.approved_at = now
      path.public_at = now
      path.promoted_at = now
      path.save!
      
      path.path_personas.create!(persona_id: Persona.first.id)
    end
    
    User.all.each do |u|
      Path.all.each do |p|
        u.enroll!(p)
      end
    end
  
    Path.all.each_with_index do |path, i|
      PATH_SECTIONS.each do |s|
        section = path.sections.create(name: s[0], category_id: default_cat.id, instructions: "Instructions to follow.")
        section.published_at = now
        section.save!
        number_of_tasks = (i+1) * 3
        
        number_of_tasks.times do |n|
          x = rand(100)
          y = rand(100)
          
          z1 = y + ((rand(6) + 1)*(rand(1) == 0 ? 1 : -1))
          z2 = y + ((rand(6) + 1)*(rand(1) == 0 ? 1 : -1))
          z3 = y + ((rand(6) + 1)*(rand(1) == 0 ? 1 : -1))
          section.tasks.create!(
            question: "What is #{x} + #{y}?",
            answer_content: [
              { content: "#{x+y}", is_correct: true },
              { content: "#{x+z1}", is_correct: false },
              { content: "#{x+z2}", is_correct: false },
              { content: "#{x+z3}", is_correct: false }
            ],
            points: 10,
            answer_type: 2,
            creator_id: moonlite_admin.id,
            reviewed_at: now,
            path_id: path.id
          )
        end
        6.times do
          section.tasks.create!(path_id: path.id, question: "Let's say you're making a footer for a website. How would you force the footer to always appear at the bottom of the page?", answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT, creator_id: moonlite_admin.id, reviewed_at: now)
        end
        section.tasks.create!(path_id: path.id, question: "This is a task1", answer_type: Task::CHECKIN, creator_id: moonlite_admin.id, reviewed_at: now)
        section.tasks.create!(path_id: path.id, question: "This is a task2", answer_type: Task::CHECKIN, creator_id: moonlite_admin.id, reviewed_at: now)
        section.tasks.create!(path_id: path.id, question: "This is a task3", answer_type: Task::CHECKIN, creator_id: moonlite_admin.id, reviewed_at: now)
      end
    end
  end
end