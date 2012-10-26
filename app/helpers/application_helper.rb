module ApplicationHelper
  def title
    base_title = company_logo || "MetaBright"
    if @title.nil?
      base_title
    else
      base_title + " | " + @title
    end
  end
  
  def admin_tabs
    [
      ["overview", "Overview", current_company],
      ["settings", "Settings", admin_settings_path],
      ["roles", "User Roles", user_roles_path],
      ["styles", "Custom Styles", styles_path],
      ["personas", "Personas", personas_path],
      ["users", "Users", admin_users_path],
    ]
  end
end
