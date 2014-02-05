Rails.configuration.middleware.use Browser::Middleware do
  # Require newest version of IE, otherwise rely on a simple modern browser check
  redirect_to upgrade_browser_path if browser.ie? && browser.version.to_i <= 9
  redirect_to upgrade_browser_path unless browser.modern?
end