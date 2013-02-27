task :move_content_to_url => :environment do
  SubmittedAnswer.all.each do |submitted_answer|
    if submitted_answer.task.youtube?
      submitted_answer.update_attribute(:url, submitted_answer.content)
    elsif submitted_answer.task.image?
      submitted_answer.update_attribute(:url, submitted_answer.content)
      submitted_answer.update_attribute(:image_url, submitted_answer.content)
    end
  end
end