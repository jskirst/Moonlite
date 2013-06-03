class Persona < ActiveRecord::Base
  attr_accessor :criteria
  attr_accessible :company_id, :name, :description, :image_url, :criteria

  belongs_to :company
  
  has_many :stored_resources, as: :owner 
  has_many :user_personas, include: :user
  has_many :users, through: :user_personas
  has_many :path_personas, include: :path
  has_many :paths, through: :path_personas, conditions: ["published_at is not ? and approved_at is not ?", nil, nil]
  has_many :public_paths, source: :path, through: :path_personas, conditions: ["published_at is not ? and approved_at is not ? and public_at is not ?", nil, nil, nil]
  
  validates :name, length: { within: 1..255 }
  validates :description, length: { within: 1..255 }
  validates :image_url, presence: true
  
  after_save do
    unless criteria.nil?
      path_personas.each do |pp|
        pp.destroy unless criteria.include?(pp.id)
      end
      criteria.each do |c|
        path_personas.create!(path_id: c) unless path_personas.find_by_id(c)
      end
    end
  end
  
  after_save :flush_cache
  before_destroy :flush_cache
    
  def picture() self.image_url.blank? ? "/images/default_achievement_pic.jpg" : self.image_url end
  def image() picture end
  
  def level(user)
    return nil unless user
    up = user_personas.find_by_user_id(user.id)
    return nil unless up
    return up.level
  end
  
  # Cached methods
  
  def self.cached_personas
    Rails.cache.fetch([self.to_s, "all"]){ Persona.all.to_a }
  end
  
  def flush_cache
    Rails.cache.delete([self.to_s, "all"])
  end
end
