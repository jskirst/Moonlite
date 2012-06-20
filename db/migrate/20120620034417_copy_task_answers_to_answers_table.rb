class CopyTaskAnswersToAnswersTable < ActiveRecord::Migration
  def change
    Task.all.each do |t|
      unless t.answer1.blank?
        existing_answer = t.answers.find_by_content(t.answer1)
        answer = t.answers.create!(:content => t.answer1, :is_correct => (t.correct_answer == 1)) unless existing_answer
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.answer_id = answer.id
            ct.save
            answer.answer_count += 1
            answer.save
          end
        end
      end
      
      unless t.answer2.blank?
        existing_answer = t.answers.find_by_content(t.answer2)
        answer = t.answers.create!(:content => t.answer2, :is_correct => (t.correct_answer == 2)) unless existing_answer
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.answer_id = answer.id
            ct.save
            answer.answer_count += 1
            answer.save
          end
        end
      end
      
      unless t.answer3.blank?
        existing_answer = t.answers.find_by_content(t.answer3)
        answer = t.answers.create!(:content => t.answer3, :is_correct => (t.correct_answer == 3)) unless existing_answer
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.answer_id = answer.id
            ct.save
            answer.answer_count += 1
            answer.save
          end
        end
      end
      
      unless t.answer4.blank?
        existing_answer = t.answers.find_by_content(t.answer4)
        answer = t.answers.create!(:content => t.answer4, :is_correct => (t.correct_answer == 4)) unless existing_answer
        t.completed_tasks.each do |ct|
          if ct.answer == answer.content && ct.answer_id.nil?
            ct.answer_id = answer.id
            ct.save
            answer.answer_count += 1
            answer.save
          end
        end
      end
    end
    
  end
end
