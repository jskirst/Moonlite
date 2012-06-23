class Category < ActiveRecord::Base
  attr_accessor :image_resource
  attr_accessible :company_id, :name, :image

  has_many :paths
  belongs_to :company
  
  validates :company_id,
  :presence      => true
  
  validates :name,
  :length      => { :within => 1..80 }
  
  before_destroy :any_paths_left?
  
  def default_image?
    return true if image == "/images/default_path_pic.jpg"
    return false
  end
  
  def image
    sr = stored_resource
    if sr
      return sr.obj.url
    else
      return "/images/default_category_pic.jpg"
    end
  end
  
  def stored_resource
    return StoredResource.find_by_owner_name_and_owner_id("category", self.id)
  end
  
  def store_image_resource(image_resource)
    if image_resource
      StoredResource.create!(:owner_name => "category", :owner_id => self.id, :obj => image_resource)
    else
      raise "RUNTIME EXCEPTION: No image resource."
    end
  end
  
  private
    def any_paths_left?
      return paths.empty?
    end
end
