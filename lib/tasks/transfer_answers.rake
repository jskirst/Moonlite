task :transfer_answers => :environment do
  Task.all.each do |t|
    # IF Fill-in-the-blank (FIB)
    if !t.answer1.blank? && t.answer2.blank? && t.answer3.blank? && t.answer4.blank?
      existing_answer = t.answers.find_by_content(t.answer1)
      answer = t.answers.create!(:content => t.answer1, :is_correct => (t.correct_answer == 1)) unless existing_answer
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
