class Mailer < ActionMailer::Base
  default from: "metabot@metabright.com"

  def welcome(details)
    @user_email = details[:email]
    @accept_url = details[:signup_link]
    mail(to: details[:email], subject: "Welcome to MetaBright!")
  end
  
  def reset(details)
    @user_email = details[:email]
    if Rails.env.production?
      @reset_url = "http://www.metabright.com/users/#{details[:token1]}/request_reset"
    else
      @reset_url = "http://localhost:3000/users/#{details[:token1]}/request_reset"
    end
    mail(to: details[:email], subject: "Password reset")
  end
  
  def invitation_alert(email)
    @email = email
    mail(to: "jskirst@gmail.com", subject: "Invitation Alert")
  end
  
  def path_result(details)
    @user = details[:user]
    @enrollment = details[:enrollment]
    @path = details[:path]
    @is_passed = @enrollment.is_passed
    @current_company = @user.company
    @name_for_paths = @current_company.name_for_paths
    if Rails.env.production?
      @retake_url = "http://www.metabright.com/paths/#{@path.id}/retake"
    else
      @retake_url = "http://localhost:3000/paths/#{@path.id}/retake"
    end
    
    @subject = @is_passed ? "Congratulations! You passed the #{@path.name} #{@name_for_paths}!" : "Your #{@path.name} results"
    
    admin_user_role_ids = @current_company.user_roles.to_a.collect { |ur| ur.id if ur.enable_administration }
    admins = @current_company.users.where("user_role_id in (?)", admin_user_role_ids)
    admin_emails = admins.to_a.collect {|a| a.email}
    puts "CC'd: #{admin_emails.join(", ")}"
    mail(to: @user.email, subject: @subject, cc: admin_emails)
  end
end
