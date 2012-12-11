class Path < ActiveRecord::Base
  def to_param
    "#{id} #{name}".parameterize
  end
  
  attr_accessor :persona_id
  attr_readonly :company_id
  attr_protected :is_approved
  attr_accessible :user_id,
    :category_id,
    :name, 
    :description, 
    :image_url,
    :is_public,
    :enable_section_display,
    :default_timer,
    :enable_nonlinear_sections,
    :is_locked, 
    :enable_retakes, 
    :tags, 
    :enable_voting,
    :passing_score,
    :enable_path_retakes,
    :is_published,
    :persona_id,
    :permalink
  
  has_one :stored_resource, as: :owner
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
  has_many :path_personas
  has_many :personas, through: :path_personas
  
  validates :name, length: { within: 2..140 }
  validates :description, length: { maximum: 2500 }
  validates :tags, length: { maximum: 250 }
  validates :user_id, presence: true
  validate do
    unless self.image_url.nil?
      self.image_url = nil if self.image_url.length < 9
    end
  end
  
  before_validation :grant_permalink
  after_create do
    self.path_personas.create(persona_id: self.persona_id)
  end
  
  def default_pic?() path_pic == "/images/image_thumb.png" end
  
  def path_pic
    return stored_resource.obj.url if stored_resource
    return self.image_url if self.image_url
    return "/images/image_thumb.png"
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
      return paths.to_a
    end
  end
  
  def self.suggested_paths(user, excluded_path_id = -1)
    personas = user.personas
    personas = user.company.personas.to_a.last(3) if personas.empty?
    enrolled_paths = user.enrolled_paths.to_a.collect &:id
    suggested_paths = personas.to_a.collect do |persona|
      persona.public_paths.to_a.collect {|path| path unless enrolled_paths.include?(path.id) } 
    end
    return suggested_paths.flatten.compact
  end
  
  def has_creative_response() tasks.where("answer_type = ?", 0).count > 0 end
  
  def current_section(current_user)
    last_task = current_user.completed_tasks.includes(:section).where(["sections.path_id = ?", self.id]).first(:order => "sections.position DESC")
    logger.debug last_task
    return sections.first if last_task.nil?
    return last_task.section
  end
  
  def next_section(section=nil)
    return sections.where(["position > ? and is_published = ?", section.position, true]).first(:order => "position ASC")
  end
  
  def tags_to_array
    return self.tags.blank? ? [] : (self.tags.split(",").collect { |t| t.strip })
  end
  
  def activity_stream
    return submitted_answers.joins(:task).where("tasks.answer_sub_type in (?)", [100,101]).last(8).to_a.collect do |a| 
      {:user => nil,
      :type => (a.task.answer_sub_type == 100 ? :text : :image),
      :content => a.content,
      :context => a.task.question,
      :date => a.created_at,
      :votes => a.total_votes}
    end
  end
  
  def grant_permalink
    if self.permalink.blank?
      new_permalink = self.name.downcase.gsub(/[^a-z]/,'')
      new_combined_permalink = new_permalink
      permalink_count = Path.where(permalink: new_combined_permalink).size
      while Path.where(permalink: new_combined_permalink).size > 0
        permalink_count += 1
        new_combined_permalink = "#{new_permalink}#{permalink_count}"
      end
      self.permalink = new_combined_permalink
    end
  end
end