task :accounting_sanity_check => :environment do
  # User.all.each do |user|
    # unless user.earned_points == user.enrollments.sum(&:total_points)
      # raise "User##{user.id} earned_points does not match sum of total_points"
    # end
  # end
  
  CompletedTask.where(status_id: Answer::CORRECT).each do |ct|
    raise "CT##{ct.id}: user cannot be found" if ct.user.nil?
    unless ct.user.user_transactions.find_by_owner_id_and_owner_type(ct.id, ct.class.to_s)
      raise "CT##{ct.id}: user_transaction cannot be found"
    end
  end
  
  Vote.all.each do |v|
    raise "V##{v.id}: user cannot be found" if v.user.nil?
    unless v.user.user_transactions.find_by_owner_id_and_owner_type(v.id, v.class.to_s)
      raise "V##{v.id}: user_transaction cannot be found"
    end
  end
end

task :user_transaction_task_to_vote_switch => :environment do
  Vote.all.each do |v|
    next if v.owner.is_a? Idea
    existing_logs = v.user.user_transactions.where(owner_id: v.id, owner_type: v.class.to_s)
    raise "V##{v.id}: #{logs.size} logs were found." if existing_logs.size > 1
    next if existing_logs.size == 1
    
    logs = v.owner.user.user_transactions.where(owner_id: v.owner.task.id, owner_type: "Task", amount: 50)
    raise "V##{v.id}: user_transaction cannot be found" + v.to_yaml unless logs.size > 0
    raise "V##{v.id}: multiple user_transactions found" + v.to_yaml unless logs.size == 1
    # if logs.size == 1
      # logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
    # else
      # if logs.first.amount.to_i == 20 or logs.first.amount.to_i == 50
        # if logs[1].amount.to_i == 100
          # logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
        # else
          # raise "CT##{ct.id}: unsure" + logs.to_yaml
        # end
      # elsif logs.first.amount.to_i == 100
        # logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
      # else
        # raise "CT##{ct.id}: #{logs.size} logs were found." + logs.to_yaml
      # end
    # end
  end
end

task :user_transaction_task_to_cp_switch => :environment do
  CompletedTask.where(status_id: Answer::CORRECT).each do |ct|
    existing_logs = ct.user.user_transactions.where(owner_id: ct.id, owner_type: ct.class.to_s)
    raise "CT##{ct.id}: #{logs.size} logs were found." if existing_logs.size > 1
    next if existing_logs.size == 1
     
    logs = ct.user.user_transactions.where(owner_id: ct.task_id, owner_type: "Task")
    raise "CT##{ct.id}: user_transaction cannot be found" unless logs.size > 0
    if logs.size == 1
      logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
    else
      if logs.first.amount.to_i == 20 or logs.first.amount.to_i == 50
        if logs[1].amount.to_i == 100
          logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
        else
          raise "CT##{ct.id}: unsure" + logs.to_yaml
        end
      elsif logs.first.amount.to_i == 100
        logs.first.update_attributes(owner_id: ct.id, owner_type: ct.class.to_s)
      else
        raise "CT##{ct.id}: #{logs.size} logs were found." + logs.to_yaml
      end
    end
  end
end

#CompletedTask.where(status_id: 1).each { |ct| ct.destroy if ct.user.user_transactions.where("owner_id = ? or owner_id = ?", ct.id, ct.task_id).size == 0 }