def new_user
  u = User.new
  u.name = Faker::Name.first_name + " " + Faker::Name.last_name
  u.email = "#{u.name.split[0][0]}#{u.name.split[1]}@gmail.com".downcase
  u.is_fake_user = true
  u.password = "awdrgy"
  u.password_confirmation = u.password
  u.save!
  return u.reload
end
    
namespace :db do
  desc "Fill database with user data"
  task :popularize => :environment do
    users = (1..5).map { new_user }
    
    open_paths = Path.where("published_at is not ? and approved_at is not ?", nil, nil)
    users.each do |u|
      open_paths.each do |p|
        if rand(2) > 0
          e = u.enroll!(p)
          tasks = p.sections.first(order: "id ASC").tasks.where("tasks.answer_type = ?", Task::MULTIPLE)
          tasks.each do |t|
            ct = u.completed_tasks.create!(task_id: t.id, status_id: Answer::INCOMPLETE)
            if rand(2) > 0
              rand_range = Random.new(12923847)
              points = rand_range.rand(51..100)
              ct.answer_id = t.correct_answer.id
              ct.status_id = Answer::CORRECT
              ct.points_awarded = points
              u.award_points(ct.task, points)
            else
              ct.answer_id = t.answers.to_a.shuffle.first
              ct.status_id = Answer::INCORRECT
              ct.points_awarded = 0   
            end
            ct.save!
          end
        end
      end
    end
  end
end