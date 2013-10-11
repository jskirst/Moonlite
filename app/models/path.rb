class Path < ActiveRecord::Base
  attr_accessor :persona, :approved, :promoted, :professional, :template_type, :batch_file
  attr_protected :approved_at, :published_at, :public_at, :promoted_at, :professional, :group_id
  attr_accessible :user_id,
    :category_id,
    :name, 
    :description, 
    :image_url,  
    :tags,
    :permalink,
    :template,
    :template_type
  
  has_one :stored_resource, as: :owner
  has_one :custom_style, as: :owner
  belongs_to :user
  belongs_to :category
  belongs_to :group
  has_many :sections
  has_many :tasks, -> { where "sections.published_at is not NULL and tasks.archived_at is NULL" }, through: :sections
  has_many :all_tasks, source: :tasks, through: :sections
  has_many :completed_tasks, through: :tasks
  has_many :submitted_answers, through: :tasks
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_users, through: :enrollments, source: :user
  has_many :user_events
  has_many :collaborations
  has_many :collaborating_users, through: :collaborations, source: :user
  has_many :path_personas, dependent: :destroy
  has_many :personas, through: :path_personas
  has_many :topics
  
  validates :name, length: { within: 2..140 }
  validates :description, length: { maximum: 2500 }
  validates :tags, length: { maximum: 250 }
  validates :user_id, presence: true
  validate do
    unless self.image_url.nil?
      self.image_url = nil if self.image_url.length < 9
    end
  end
  
  after_create { user.enroll!(self) }
  before_validation :grant_permalink
  after_save do
    flush_cache
  end
  after_destroy do
    flush_cache
  end
  
  def published?() published_at.nil? ? false : true end
  def public?() public_at.nil? ? false : true end
  def approved?() approved_at.nil? ? false : true end
  def promoted?() promoted_at.nil? ? false : true end
  def professional?() professional_at.nil? ? false : true end
  
  def path_pic
    return self.image_url if self.image_url
    return ICON_DEFAULT_PATH
  end
  def image() path_pic end
  def picture() path_pic end
  def default_pic?() path_pic == ICON_DEFAULT_PATH end
  
  def self.with_name_like(name, user)
    return Path.where("locked_at is ? and published_at is ? and name ILIKE ?", nil, true, "%#{name}%")
  end
  
  def self.with_tags_like(tags, user, excluded_path_id)
    return [] if tags.empty?
    conditions = []
    base_query = ["locked_at is ?", "published_at is not ?", "paths.id != ?"]
    query_variables = [nil, nil, excluded_path_id]
    
    tags_query = []
    tags.each do |t|
      tags_query << "tags ILIKE ?"
      query_variables << "%#{t}%"
    end
    query = "(#{base_query.join(" and ")}) and (#{tags_query.join(" or ")})"
    conditions = [query] + query_variables
    return Path.where(conditions)
  end
  
  def similar_paths
    return personas.first.paths.where("public_at is not ? and published_at is not ? and approved_at is not ?", nil, nil, nil)
  end
  
  def self.suggested_paths(user = nil, excluded_path_id = -1)
    if user
      personas = user.personas
      personas = Persona.last(3) if personas.empty?
      enrolled_paths = user.enrolled_paths.to_a.collect &:id
      suggested_paths = personas.to_a.collect do |persona|
        cached_find_by_persona_id(persona.id).collect {|path| path unless enrolled_paths.include?(path.id) } 
      end
    else
      raise "User should not be nil"
    end
    return suggested_paths.flatten.compact.first(8)
  end
  
  def has_creative_response() tasks.where("answer_type = ?", 0).count > 0 end
  
  def current_section(current_user)
    last_task = current_user.completed_tasks.includes(:section).where(["sections.path_id = ?", self.id]).first(:order => "sections.position DESC")
    logger.debug last_task
    return sections.first if last_task.nil?
    return last_task.section
  end
  
  def next_section(section=nil)
    position = section ? section.position : 0
    return sections.where(["position > ? and published_at is not ?", position, nil]).first(order: "position ASC")
  end
  
  def next_section_for_user(user)
    section = user.most_recent_section_for_path(self) || next_section
    while section && section.completed?(user)
      section = next_section(section)
    end
    return section
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
  
  def self.by_popularity(limit = nil)
    paths = Path.select("paths.*, count(enrollments.id) as enrollments_count")
      .joins("LEFT JOIN enrollments on enrollments.path_id = paths.id")
      .group("paths.id")
      .order("enrollments_count DESC")
    return paths.limit(limit) if limit
    return paths
  end
  
  def can_add_tasks?(user)
    if self.group_id and (not user.group_users.where(group_id: self.group_id, is_admin: true))
      return false
    else
      return true
    end
  end
  
  def metascore_available?
    not self.percent_correct.nil?
  end
  
  # Cached methods
  
  def self.cached_find(permalink)
    begin
      Rails.cache.fetch([self.to_s, permalink]) { find_by_permalink(permalink) }
    rescue
      raise "Rails cache failed."
    end
  end
  
  def self.cached_find_by_id(id)
    Rails.cache.fetch([self.to_s, id]) { find_by_id(id) }
  end
  
  def self.cached_find_by_persona_id(persona_id)
    Rails.cache.fetch([self.to_s, "by_persona", persona_id]) do
      Path.joins(:path_personas)
        .where("path_personas.persona_id = ?", persona_id)
        .where("published_at is not ? and approved_at is not ? and public_at is not ?", nil, nil, nil)
        .to_a
    end
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name, permalink])
    Rails.cache.delete([self.class.name, id])
    Persona.all.each do |persona|
      Rails.cache.delete([self.class.name, "by_persona", persona.id])
    end
  end
end