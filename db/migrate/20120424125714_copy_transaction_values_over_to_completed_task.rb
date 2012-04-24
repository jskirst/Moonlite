class CopyTransactionValuesOverToCompletedTask < ActiveRecord::Migration
  def change
		CompletedTask.where("status_id = ? and points_awarded is ?", 1, nil).each do |cp|
			t = UserTransaction.where("task_id = ? and user_id = ?", cp.task_id, cp.user_id).first
			unless t.nil?
				cp.points_awarded = t.amount
				cp.save
			end
		end
  end
end
