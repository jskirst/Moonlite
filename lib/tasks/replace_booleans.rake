task :replace_booleans => :environment do
  Enrollment.all.each { |e| e.update_attribute(:contribution_unlocked_at, e.created_at) if e.contribution_unlocked }
  User.all.each { |u| u.update_attribute(:locked_at, Time.now) if u.is_locked }
  Path.all.each { |p| p.update_attribute(:approved_at, Time.now) if p.is_approved }
  Path.all.each { |p| p.update_attribute(:published_at, Time.now) if p.is_published }
  Path.all.each { |p| p.update_attribute(:public_at, Time.now) if p.is_public }
  Section.all.each { |s| s.update_attribute(:published_at, Time.now) if s.is_published }
  TaskIssue.all.each { |i| i.update_attribute(:resolved_at, Time.now) if i.resolved }
  Task.all.each { |t| t.update_attribute(:reviewed_at, Time.now) if t.is_reviewed }
  Task.all.each { |t| t.update_attribute(:locked_at, Time.now) if t.is_locked }
  UserEvent.all.each { |e| e.update_attribute(:read_at, Time.now) if e.is_read }
  Comment.all.each { |c| c.update_attribute(:reviewed_at, Time.now) if c.is_reviewed }
  Comment.all.each { |c| c.update_attribute(:locked_at, Time.now) if c.is_locked }
  SubmittedAnswer.all.each { |sa| sa.update_attribute(:reviewed_at, Time.now) if sa.is_reviewed }
  SubmittedAnswer.all.each { |sa| sa.update_attribute(:locked_at, Time.now) if sa.is_locked }
  Persona.all.each { |p| p.update_attribute(:locked_at, Time.now) if p.is_locked }
end