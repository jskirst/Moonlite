task :stored_resource_switch => :environment do
  StoredResource.all.each do |sr|
    if !sr.path_id.nil?
      sr.owner_type = "Path"
      sr.owner_id = sr.path_id
    elsif !sr.section_id.nil?
      sr.owner_type = "Section"
      sr.owner_id = sr.section_id
    elsif !sr.task_id.nil?
      sr.owner_type = "Task"
      sr.owner_id = sr.task_id
    else
      raise "RUNTIME EXCEPTION: unknown object id for SR ##{sr.id}"
    end
    
    unless sr.save
      raise "RUNTIME EXCEPTION: SR could not save"
    end
  end
end