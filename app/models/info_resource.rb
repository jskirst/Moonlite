class InfoResource < ActiveRecord::Base
	attr_accessible :path_id, :section_id, :task_id, :description, :link, :info_type
	
	belongs_to :path
  belongs_to :section
  belongs_to :task
	
	validates :description,
		:length			=> { :maximum => 255 }

	validates :link,
		:length			=> { :within => 1..255 }
    
  validates :info_type, 
		:presence 		=> true
    
	validate :has_path_or_section_or_task
	validate :is_valid_info_type
    
  private
    def has_path_or_section_or_task
      error = "Info resource requires one of the following: Path, Section or Task."
			if path.nil? && section.nil? && task.nil?
				errors[:base] << error
			elsif !path.nil? && !(section.nil? && task.nil?)
				errors[:base] << error
			elsif !section.nil? && !(path.nil? && task.nil?)
				errors[:base] << error
			elsif !task.nil? && !(path.nil? && section.nil?)
				errors[:base] << error
			end
		end
    
    def is_valid_info_type
      valid_types = ["text", "video", "picture", "action", "slideshow"]
      unless valid_types.include?(self.info_type)
        errors[:base] << "Info type must be of one of the following: "+valid_types.join(", ") +". Your type was: "+self.info_type.to_s
      end
    end
end
