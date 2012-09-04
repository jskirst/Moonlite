class Path < ActiveRecord::Base
  # def to_param
    # "#{id} #{name}".parameterize
  # end
  
  attr_readonly :company_id
  attr_protected :is_published, :is_purchaseable
  attr_accessible :user_id,
    :category_id,
    :name, 
    :description, 
    :image_url,
    :is_public,
    :enable_section_display,
    :default_timer, 
    :excluded_from_leaderboards, 
    :enable_nonlinear_sections,
    :is_locked, 
    :enable_retakes, 
    :game_type, 
    :tags, 
    :enable_voting,
    :passing_score,
    :enable_path_retakes
  
  has_many :stored_resources, as: :owner
  belongs_to :user
  belongs_to :company
  belongs_to :category
  has_many :sections, dependent: :destroy
  has_many :tasks, through: :sections, conditions: ["sections.is_published = ?", true]
  has_many :completed_tasks, through: :tasks
  has_many :submitted_answers, through: :tasks
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_users, through: :enrollments, source: :user
  has_many :path_user_roles, dependent: :destroy
  has_many :user_roles, through: :path_user_roles
  has_many :user_events
  has_many :collaborations
  has_many :collaborating_users, through: :collaborations, source: :user
  
  validates :name, length: { within: 2..140 }
  validates :description, length: { maximum: 2500 }
  validates :tags, length: { maximum: 250 }
  validates :user_id, presence: true
  validate do
    unless self.image_url.nil?
      self.image_url = nil if self.image_url.length < 9
    end
  end
  
  def default_pic?
    return path_pic == "/images/default_path_pic.jpg"
  end
  
  def path_pic
    sr = stored_resources.first
    return sr.obj.url if sr
    return self.image_url if self.image_url
    return "/images/default_path_pic.jpg"
  end
  
  def self.with_category(type, user, excluded_ids = -2, order = "id DESC")
    if excluded_ids.is_a?(Integer)
      return Path.joins(:path_user_roles).where("path_user_roles.user_role_id = ? and is_published = ? and category_id = ? and paths.id != ?", user.user_role_id, true, "#{type}", excluded_ids).all(:order => "is_locked, "+order)
    else
      return Path.where("is_published = ? and category_id = ? and id NOT IN (?)", true, "#{type}", excluded_ids).all(:order => "is_locked, "+order)
    end
  end
  
  def self.with_name_like(name, user)
    return Path.joins(:path_user_roles).where("is_locked = ? and path_user_roles.user_role_id = ? and is_published = ? and name ILIKE ?", false, user.user_role_id, true, "%#{name}%")
  end
  
  def self.with_tags_like(tags, user, excluded_path_id)
    return [] if tags.empty?
    conditions = []
    base_query = ["is_locked = ?", "is_published = ?", "path_user_roles.user_role_id = ?", "paths.id != ?"]
    query_variables = [false, true, user.user_role_id, excluded_path_id]
    
    tags_query = []
    tags.each do |t|
      tags_query << "tags ILIKE ?"
      query_variables << "%#{t}%"
    end
    query = "(#{base_query.join(" and ")}) and (#{tags_query.join(" or ")})"
    conditions = [query] + query_variables
    return Path.joins(:path_user_roles).where(conditions)
  end
  
  def self.similar_paths(path, user)
    paths = Set.new
    unless path.nil?
      Path.with_tags_like(path.tags_to_array, user, path.id).each {|p| paths << p}
      Path.with_category(path.category_id, user, path.id, "id DESC").each {|p| paths << p}
      return paths.to_a
    else
      return Path.with_category(user.company.categories.first.id, user)
    end
  end
  
  def self.suggested_paths(user, excluded_path_id = -1)
    paths = user.enrolled_paths
    enrolled_path_ids = []
    if paths.empty?
      return Path.with_category(user.company.categories.first.id, user)
    else
      category_counter = {}
      paths.each do |p|
        enrolled_path_ids << p.id
        category_counter[p.category_id] = category_counter[p.category_id].to_i + 1
      end
      category_counter = category_counter.sort_by { |k,v| v }
      category_counter = category_counter
      return Path.with_category(category_counter.to_a[-1][0].to_i, user, enrolled_path_ids)
    end
  end
  
  def has_creative_response
    return tasks.where("answer_type = ?", 0).count > 0
  end
  
  def current_section(current_user)
    last_task = current_user.completed_tasks.includes(:section).where(["sections.path_id = ?", self.id]).first(:order => "sections.position DESC")
    logger.debug last_task
    return sections.first if last_task.nil?
    return last_task.section
  end
  
  def next_section(section=nil)
    return sections.where(["position > ? and is_published = ?", section.position, true]).first(:order => "position ASC")
  end
  
  def completed?(user)
    enrollment = enrollments.find_by_user_id(user.id)
    return false if enrollment.nil?
    return enrollments.find_by_user_id(user.id).is_complete?
  end
  
  def total_remaining_tasks(user)
    remaining_tasks = 0
    if self.enable_retakes
      remaining_tasks = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id and completed_tasks.status_id IN (?))", user.id, [1,2]]).count
    else
      remaining_tasks = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id)", user.id]).count
    end
    return remaining_tasks
  end
  
  def percent_complete(user)
    total_tasks = tasks.size
    total_remaining = total_remaining_tasks(user)
    return (((total_tasks - total_remaining.to_f) / total_tasks.to_f) * 100).to_i
  end
 
  def enrolled_user_count
    return enrollments.count
  end
  
  def difficulty_rating
    task_count = tasks.count
    return "Easy" if task_count < 50
    return "Medium" if task_count < 150
    return "Hard"
  end
  
  def deep_clone(company)
    cloned_path = self.dup
    cloned_path.company_id = company.id
    cloned_path.user_id = company.users.first.id
    cloned_path.category_id = nil
    cloned_path.save
    
    sections.each do |s|
      cloned_section = s.dup
      cloned_section.path_id = cloned_path.id
      cloned_section.save
      s.tasks.each do |t|
        cloned_task = t.dup
        cloned_task.section_id = cloned_section.id
        cloned_task.save
      end
    end
    return cloned_path
  end
  
  def import_tasks_from(from_path)
    from_path.tasks.each do |t|
      if tasks.find_by_question(t.question).nil?
        imported_task = t.dup
        imported_task.section_id = sections.first.id
        imported_task.save
      end
    end
  end
  
  def tags_to_array
    return self.tags.blank? ? [] : (self.tags.split(",").collect { |t| t.strip })
  end
  
  def activity_stream
    start_time = Time.now
    events = user_events.joins(:user).last(8).to_a.collect  do |e| 
      {:user => e.user, 
      :type => :event, 
      :content => e,
      :date => e.created_at}
    end
    answers = submitted_answers.joins(:task).where("tasks.answer_sub_type in (?)", [100,101]).last(8).to_a.collect do |a| 
      {:user => nil,
      :type => (a.task.answer_sub_type == 100 ? :text : :image),
      :content => a.content,
      :context => a.task.question,
      :date => a.created_at,
      :votes => a.total_votes}
    end
    stream = (events + answers).sort {|a,b| b[:date] <=> a[:date]}
    # raise stream.to_yaml
    return stream
  end
  
  def percentage_correct(user = nil)
    if user.nil?
      number_of_tasks = completed_tasks.where("status_id = ?", 1).size
      correct_answers = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.task_id = tasks.id and completed_tasks.status_id = 0)"]).count
      return 0 if correct_answers == 0 || number_of_tasks == 0
    else
      number_of_tasks = tasks.size
      correct_answers = tasks.where(["NOT EXISTS (SELECT * FROM completed_tasks WHERE completed_tasks.user_id = ? and completed_tasks.task_id = tasks.id and completed_tasks.status_id = 0)", user.id]).count
      return 0 if correct_answers == 0 || number_of_tasks == 0
    end
    return ((correct_answers.to_f / number_of_tasks.to_f) * 100).to_i
  end
  
  def create_completion_event(user, name_for_paths)
    if user.user_events.where("path_id = ? and content LIKE ?", self.id, "%completed%").empty?
      total_earned_points = enrollments.find_by_user_id(user.id).total_points.to_i
      event = "<%u%> completed the <%p%> #{name_for_paths} with a score of #{total_earned_points.to_s}."
      user.user_events.create!(path_id: self.id, content: event)
    end
  end
end