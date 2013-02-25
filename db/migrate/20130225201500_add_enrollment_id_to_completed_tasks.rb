class AddEnrollmentIdToCompletedTasks < ActiveRecord::Migration
  def change
    add_column :completed_tasks, :enrollment_id, :integer
    
    CompletedTask.all.each do |ct|
      next if ct.enrollment_id
      next if ct.task.nil? or ct.user.nil? or ct.task.path.nil?
      enrollment = ct.user.enrollments.find_by_path_id(ct.task.path.id)
      next if enrollment.nil?
      
      ct.enrollment_id = enrollment.id
      ct.save
    end
  end
end
