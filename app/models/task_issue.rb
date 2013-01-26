class TaskIssue < ActiveRecord::Base
  SPAM      = 1
  SPELLING  = 2
  MISPLACED = 3
  REPEAT    = 4
  QUALITY   = 5
  COPYRIGHT = 6
  
  ISSUE_TYPES = [SPAM, SPELLING, MISPLACED, REPEAT, QUALITY, COPYRIGHT]
  ISSUE_TYPE_CONTENT = {
    SPAM => "Unwanted commercial content or spam",
    SPELLING => "Spelling or grammatical error",
    MISPLACED => "Doesn't belong in this section or Challenge",
    REPEAT => "Too similar to another question",
    QUALITY => "So poor that it detracts from the Challenge",
    COPYRIGHT => "Copyrighted material"
  }
  
  attr_accessible :task_id, :issue_type, :resolved
  
  belongs_to :user
  belongs_to :task
  
  validates :user_id, presence: true, uniqueness: { scope: :task_id }
  validates :task_id, presence: true
  validates_inclusion_of :issue_type, in: ISSUE_TYPES
  
  after_create do
    if task.task_issues.where(resolved: false).size >= 2 || user.user_role.enable_administration
      task.update_attribute(:is_locked, true)
      creator = task.creator
      creator.enroll!(task.path)
      task.creator.retract_points(task, 100)
    end
  end
end
