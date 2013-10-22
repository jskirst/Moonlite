module AdminHelper
  def admin_tabs
    [
      ["overview", "Overview", admin_overview_path],
      ["funnel", "Funnel", admin_funnel_path],
      ["visits", "Visits", admin_visits_path],
      ["personas", "Personas", personas_path],
      ["paths", "Paths", admin_paths_path],
      ["users", "Users", admin_users_path],
      ["submissions", "Submissions", admin_submissions_path],
      ["tasks", "Tasks", admin_tasks_path],
      ["comments", "Comments", admin_comments_path],
      ["groups", "Groups", admin_groups_path],
      ["email", "Email", admin_email_path]
    ]
  end
  
  class Email
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    
    attr_accessor :to_email, :to_name, :from, :subject, :body, :preview
    
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
    
    def self.model_name()
      ActiveModel::Name.new(self, nil, "Email")
    end
    
    def persisted?
      false
    end
  end
end