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