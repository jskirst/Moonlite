class Search
  # Rails 4: include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :path_ids, :paths, 
    :country, :state, 
    :part_time, :full_time, :internship, :any_opp, 
    :users, :results
    #:selects, :joins
  
  validates_presence_of :paths
  validates_presence_of :country
  
  def initialize
  end
  
  def submit(p)
    self.paths = p[:paths]
    self.country = p[:country]
    self.state = p[:state]
    self.part_time = p[:part_time]
    self.full_time = p[:full_time]
    self.internship = p[:internship]
    
    if valid?
      return results
    else
      return false
    end
  end
  
  def results
    init_users
    
    sort_by_paths
    sort_by_seeking
    
    sort_by_country
    sort_by_state
    
    construct_results
  end
  
  def init_users
    self.users = User.where("locked_at is ?", nil).select("users.id, users.name").group("users.id")
  end
  
  def sort_by_paths
    self.path_ids = []
    orders = []
    paths.each do |id,status|
      id = id.to_i.to_s
      self.path_ids << id
      self.users = users.joins("LEFT JOIN enrollments e#{id} on e#{id}.user_id=users.id and e#{id}.path_id = #{id}")
      select = "e#{id}.path_id as e#{id}_path_id, coalesce(e#{id}.total_points,0) as e#{id}_total_points, coalesce(e#{id}.metascore, 0) as e#{id}_metascore, coalesce(e#{id}.metapercentile,0) as e#{id}_metapercentile"
      group = "e#{id}.path_id, e#{id}.total_points, e#{id}.metascore, e#{id}.metapercentile"
      self.users = users.select(select)
      self.users = users.group(group)
      
      #orders << "e#{id}.metascore DESC NULLS LAST"
      orders << "coalesce(e#{id}.metascore,0)"
    end
    sum = "SUM(#{orders.join(" + ")})"
    avg = "(#{sum}/#{paths.size}::float)"
    self.users = users.select("#{avg} as avg_metascore")
    self.users = users.order("#{avg} DESC")
    self.users = users.order(orders.join(","))
  end
  
  def sort_by_country
    self.users = self.users.to_a unless self.users.is_a? Array
    unless country == "ALL"
      # Return - 1 if b is closer to desired country then a
      # Return 0 if they are the same distance
      # Return + 1 if first a is closer than b
      self.users.sort |a, b|
        if a.country == self.country and b.country == self.country
          return 0
      self.users = users.where("country = ?", country)
    end
  end
  
  def sort_by_state
    unless country == "ALL" or state == "ALL"
      self.users = users.where("state = ?", state)
    end
  end
  
  def sort_by_seeking
    all_blank = not(full_time or part_time or internship)
    conditions = []
    conditions << "wants_full_time = ?" if full_time or all_blank
    conditions << "wants_part_time = ?" if part_time or all_blank
    conditions << "wants_internship = ?" if internship or all_blank
    truths = conditions.size
    conditions = [conditions.join(" OR ")]
    truths.times { conditions << true }
    self.users = users.where(conditions)
  end
  
  def construct_results
    self.users = users.to_a.select{ |u| u.avg_metascore.to_i > 0 }
    self.users = users.collect do |u|
      enrollments = path_ids.collect do |path_id|
        {
          path_id: u["e#{path_id}_path_id"],
          total_points: u["e#{path_id}_total_points"],
          metascore: u["e#{path_id}_metascore"],
          metapercentile: u["e#{path_id}_metapercentile"]
        }
      end
      { user_id: u["id"], name: u["name"], enrollments: enrollments, total_metascore: u["avg_metascore"], price: (u["avg_metascore"].to_f / 50).round(2) }
    end
    self.paths = Path.where("paths.id in (?)", path_ids)
    return { paths: paths, users: users.to_a }
  end
  
  def self.rating(perc)
    perc = perc.to_i
    return "Extremely Talented" if perc > 90
    return "Very Talented" if perc > 80
    return "Good" if perc > 70
    return "Above Average" if perc > 60
    return "Average" if perc > 40
    return "Below Average" if perc > 20
    return "Poor" if perc > 0
    return "Unknown" if perc == 0
  end
  
  def persisted?() false end
end