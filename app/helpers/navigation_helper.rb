module NavigationHelper
  def hide_background
    return @hide_background.nil? ? false : @hide_background
  end
  
  def show_header
    return @show_header.nil? ? true : @show_header
  end
  
  def show_sign_in
    return @show_sign_in.nil? ? true : @show_sign_in
  end
  
  def show_footer
    return @show_footer.nil? ? true : @show_footer
  end
  
  def show_nav_bar
    return @show_nav_bar.nil? ? true : @show_nav_bar
  end
  
  def show_employer_link
    return @show_employer_link unless @show_employer_link.nil?
    return show_sign_in
  end
end