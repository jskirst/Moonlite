task :stored_resource_switch => :environment do
  StoredResource.all.each do |sr|
    if !sr.path_id.nil?
      sr.owner_type = "Path"
      sr.owner_id = sr.path_id
    elsif !sr.section_id.nil?
      sr.owner_type = "Section"
      sr.owner_id = sr.section_id
    elsif !sr.task_id.nil?
      sr.owner_type = "Task"
      sr.owner_id = sr.task_id
    else
      raise "RUNTIME EXCEPTION: unknown object id for SR ##{sr.id}"
    end
    
    unless sr.save
      raise "RUNTIME EXCEPTION: SR could not save"
    end
  end
end

task :transfer_answers => :environment do
  Task.all.each do |t|
    # IF Fill-in-the-blank (FIB)
    if !t.answer1.blank? && t.answer2.blank? && t.answer3.blank? && t.answer4.blank?
      answer = (t.answers.find_by_content(t.answer1) || t.answers.create!(:content => t.answer1, :is_correct => (t.correct_answer == 1)))
      t.update_attribute(:answer_type, 1)
      t.completed_tasks.each do |ct|
        if answer.content.downcase.include?(ct.answer.to_s.downcase) && ct.answer_id.nil?
          ct.update_attribute(:answer_id, answer.id)
          answer.update_attribute(:answer_count, (answer.answer_count + 1))
        end
      end
    # IF Multiple choice
    else
      unless t.answer1.blank?
        answer = (t.answers.find_by_content(t.answer1) || t.answers.create!(:content => t.answer1, :is_correct => (t.correct_answer == 1)))
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.update_attribute(:answer_id, answer.id)
            answer.update_attribute(:answer_count, (answer.answer_count + 1))
          end
        end
      end
      
      unless t.answer2.blank?
        answer = (t.answers.find_by_content(t.answer2) || t.answers.create!(:content => t.answer2, :is_correct => (t.correct_answer == 2)))
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.update_attribute(:answer_id, answer.id)
            answer.update_attribute(:answer_count, (answer.answer_count + 1))
          end
        end
      end
      
      unless t.answer3.blank?
        answer = (t.answers.find_by_content(t.answer3) || t.answers.create!(:content => t.answer3, :is_correct => (t.correct_answer == 3)))
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.update_attribute(:answer_id, answer.id)
            answer.update_attribute(:answer_count, (answer.answer_count + 1))
          end
        end
      end
      
      unless t.answer4.blank?
        answer = (t.answers.find_by_content(t.answer4) || t.answers.create!(:content => t.answer4, :is_correct => (t.correct_answer == 4)))
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.update_attribute(:answer_id, answer.id)
            answer.update_attribute(:answer_count, (answer.answer_count + 1))
          end
        end
      end
    end
  end
end

task :user_transaction_switch => :environment do
  puts "Starting switch"
  counter = 0
  UserTransaction.all.each do |ut|
    if ut.path_id
      ut.owner_type = "Path"
      ut.owner_id = ut.path_id
    elsif ut.reward_id
      ut.owner_type = "Reward"
      ut.owner_id = ut.reward_id
    elsif ut.task_id
      ut.owner_type = "Task"
      ut.owner_id = ut.task_id
    else
      raise "RUNTIME EXCEPTION: unknown object id for ut ##{ut.id}"
    end
    
    unless ut.save
      raise "RUNTIME EXCEPTION: ut could not save"
    end
    counter += 1
    if counter % 100 == 0
      puts counter.to_s
    end
  end
end