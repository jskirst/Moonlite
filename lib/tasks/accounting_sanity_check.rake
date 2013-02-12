task :accounting_sanity_check => :environment do
  User.all.each do |user|
    unless user.earned_points == user.enrollments.sum(&:total_points)
      raise "User##{user.id} earned_points does not match sum of total_points"
    end
  end
  
  CompletedTask.all.each do |ct|
    raise "CT##{ct.id}: user cannot be found" if ct.user.nil?
    unless ct.user.user_transactions.find_by_owner_id_and_owner_type(ct.id, ct.class.to_s)
      raise "CT##{ct.id}: user_transaction cannot be found"
    end
  end
end

task :user_transaction_task_to_cp_switch => :environment do
  CompletedTask.all.each do |ct|
    #logs = ct.user.user_transactions.where(:)
  end
end