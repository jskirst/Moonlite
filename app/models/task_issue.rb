class TaskIssue < ActiveRecord::Base
  SPAM      = 1
  SPELLING  = 2
  MISPLACED = 3
  REPEAT    = 4
  QUALITY   = 5
  COPYRIGHT = 6
  WRONG     = 7
  
  ISSUE_TYPES = [SPAM, SPELLING, MISPLACED, REPEAT, QUALITY, COPYRIGHT, WRONG]
  ISSUE_TYPES_SHORT = {
    SPAM => "Spam",
    SPELLING => "Spelling",
    MISPLACED => "Misplaced",
    REPEAT => "Repeat",
    QUALITY => "Quality",
    COPYRIGHT => "Copyrighted",
    WRONG => "Incorrect"
  }
  ISSUE_TYPE_CONTENT = {
    SPAM => "Unwanted commercial content or spam",
    SPELLING => "Spelling or grammatical error",
    MISPLACED => "Doesn't belong in this section or Challenge",
    REPEAT => "Too similar to another question",
    QUALITY => "So poor that it detracts from the Challenge",
    COPYRIGHT => "Copyrighted material",
    WRONG => "Incorrect answer"
  }
  
  attr_accessible :task_id, :issue_type, :resolved
  
  belongs_to :user
  belongs_to :task
  
  validates :user_id, presence: true, uniqueness: { scope: :task_id }
  validates :task_id, presence: true
  validates_inclusion_of :issue_type, in: ISSUE_TYPES
  
  after_create do
    if user.user_role.enable_administration || task.task_issues.where(resolved: false).size >= 2
      task.update_attribute(:locked_at, Time.now)
      creator = task.creator
      creator.enroll!(task.path)
      creator.retract_points(task, Task::CREATOR_PENALTY_POINTS)
    end
  end
end
