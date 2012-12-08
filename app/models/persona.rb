class Persona < ActiveRecord::Base
  attr_accessor :criteria
  attr_accessible :company_id, :name, :description, :image_url, :criteria, :is_locked

  belongs_to :company
  
  has_many :stored_resources, as: :owner 
  has_many :user_personas, include: :user
  has_many :users, through: :user_personas
  has_many :path_personas, include: :path
  has_many :paths, through: :path_personas, conditions: { is_published: true, is_approved: true, is_public: true }
  
  validates :name, length: { :within => 1..255 }
  validates :description, length: { :within => 1..255 }
  validates :image_url, presence: true
  
  after_save do
    unless criteria.nil?
      path_personas.each do |pp|
        pp.destroy unless criteria.include?(pp.id)
      end
      criteria.each do |c|
        unless path_personas.find_by_id(c)
          path_personas.create!(:path_id => c)
        end
      end
    end
  end
    
  def picture
    return self.image_url unless self.image_url.nil?
    return "/images/default_achievement_pic.jpg"
  end
  
  def level(user)
    return nil unless user
    up = user_personas.find_by_user_id(user.id)
    return nil unless up
    return up.level
  end
end
