task :moving_supplied_answer_to_completed_task => :environment do
  CompletedTask.where(answer: nil).all.each do |ct|
    unless ct.answer_id.blank?
      answer = Answer.find_by_id(ct.answer_id)
      unless answer
        puts "Skipping answer doesn't exist"
        next
      end
      ct.answer = answer.content
      if ct.enrollment_id.blank?
        path = ct.path
        if path
          e = ct.user.enrollments.find_by_path_id(path.id)
          ct.enrollment_id = e.id
        else
          puts "Skipping as path no longer exists"
          next
        end
      end
      ct.save!
    end
  end
end