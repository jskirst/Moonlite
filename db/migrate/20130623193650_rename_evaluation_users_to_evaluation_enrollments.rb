class RenameEvaluationUsersToEvaluationEnrollments < ActiveRecord::Migration
  def change
    rename_table :evaluation_users, :evaluation_enrollments 
  end
end
