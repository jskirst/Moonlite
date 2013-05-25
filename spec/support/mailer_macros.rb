module MailerMacros
  def emails
    ActionMailer::Base.deliveries
  end
  
  def last_email
    ActionMailer::Base.deliveries.last
  end
  
  def last_email_to
    last_email.to.join()
  end
  
  def reset_email
    ActionMailer::Base.deliveries = []
  end
end