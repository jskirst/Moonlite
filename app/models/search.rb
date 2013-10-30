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
    sort_by_location
    
    construct_results
  end
  
  def init_users
    self.users = User.where("locked_at is ?", nil)
      .select("users.id, users.name, users.longitude, users.latitude, users.city, users.state, users.country")
      .where("users.longitude is not ? and users.latitude is not ?", nil, nil)
      .group("users.id")
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
  
  def sort_by_seeking
    #all_blank = not(full_time or part_time or internship)
    all_blank = true
    conditions = []
    conditions << "wants_full_time = ?" if full_time or all_blank
    conditions << "wants_part_time = ?" if part_time or all_blank
    conditions << "wants_internship = ?" if internship or all_blank
    truths = conditions.size
    conditions = [conditions.join(" OR ")]
    truths.times { conditions << true }
    self.users = users.where(conditions)
  end
  
  def sort_by_location
    self.users = self.users.to_a unless self.users.is_a? Array
    unless self.country == "ALL"
      location = self.country
      location = self.state + ", " + location
      computed_location = Geocoder.search(location).first
      lat = computed_location.data["geometry"]["location"]["lat"]
      lng = computed_location.data["geometry"]["location"]["lng"]
      self.users = self.users.collect do |u|
        u.attributes.merge(
          "distance" => Geocoder::Calculations.distance_between([u.latitude, u.longitude], [lat, lng]),
          "location" => "#{u["state"]}, #{Carmen::Country.coded(u["country"]).name}")
      end
      self.users.sort! { |a,b| (a["distance"] || 1000000).to_f <=> (b["distance"] || 10000000).to_f }
    else
      self.users.collect do |u|
        u_hash = u.attributes
      end
    end
  end
  
  def construct_results
    self.users = users.select{ |u| u["avg_metascore"].to_i > 0 }
    self.users = users.collect do |u|
      enrollments = path_ids.collect do |path_id|
        {
          path_id: u["e#{path_id}_path_id"],
          total_points: u["e#{path_id}_total_points"],
          metascore: u["e#{path_id}_metascore"],
          metapercentile: u["e#{path_id}_metapercentile"]
        }
      end
      { user_id: u["id"], name: u["name"], enrollments: enrollments, total_metascore: u["avg_metascore"], price: (u["avg_metascore"].to_f / 50).round(2), location: u["location"] }
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