def new_user
  u = User.new
  u.name = Faker::Name.first_name + " " + Faker::Name.last_name
  u.email = "#{u.name.split[0][0]}#{u.name.split[1]}@gmail.com".downcase
  u.is_fake_user = true
  u.password = "awdrgy"
  u.password_confirmation = u.password
  u.company_id = Company.first.id
  u.user_role_id = UserRole.first.id
  u.save!
  return u.reload
end
    
namespace :db do
  desc "Fill database with user data"
  task :popularize => :environment do
    users = (1..5).map { new_user }
    
    open_paths = Path.where("is_published = ? and is_approved = ?", true, true)
    users.each do |u|
      open_paths.each do |p|
        if rand(2) > 0
          e = u.enroll!(p)
          tasks = p.sections.first(order: "id ASC").tasks.where("tasks.answer_type = ?", Task::MULTIPLE)
          tasks.each do |t|
            if rand(2) > 0
              answer = t.correct_answer
            else
              answer = t.answers.to_a.shuffle.first
            end
            score = rand(51..100)
            ct = u.completed_tasks.create!(task_id: t.id, status_id: Answer::INCOMPLETE)
            ct.complete_multiple_choice(answer.id, score)
          end
        end
      end
    end
  end
end