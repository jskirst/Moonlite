def create_user
  u = User.new
  u.name = Faker::Name.name
  u.email = "#{u.name.split[0][0]}#{u.name.split[1]}@gmail.com".downcase
  u.is_fake_user = true
  u.password = "awdrgy"
  u.password_confirmation = u.password
  u.company_id = Company.first.id
  u.user_role_id = UserRole.first.id
  u.save
  return u
end
    
namespace :db do
  desc "Fill database with user data"
  task :popularize => :environment do
    users = (1..20).map { create_user }
    
    open_paths = Paths.where("is_published = ? and is_approved = ?")
    users.each do |u|
      open_paths.each do |p|
        if rand(5) == 4
          e = u.enroll!(p)
          tasks = p.sections.first(order: "id ASC").tasks
          tasks.each do |t|
            ct =  
          end
        end
      end
    end
  end
end