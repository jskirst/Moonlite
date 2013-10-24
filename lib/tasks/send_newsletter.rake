# Test run code:
# NLTEST=jskirst@gmail.com NLNAME=newsletter_10232013 NLSUBJECT='Big news from MetaBright' rake send_newsletter
# NLTEST=nathanielsokollward@gmail.com NLNAME=newsletter_10232013 NLSUBJECT='Big news from MetaBright' rake send_newsletter
# Production run code: 
# NLNAME=newsletter_10232013 NLSUBJECT='Big news from MetaBright' rake send_newsletter

task :send_newsletter => :environment do
  raise "Fatal: No newsletter specified" unless ENV["NLNAME"]
  if ENV["NLTEST"]
    puts "Sending to test email: #{ENV['NLTEST']}"
    user = User.where(email: ENV["NLTEST"]).first
    User.send_all_newsletters(ENV["NLNAME"], ENV["NLSUBJECT"], user)
  else
    puts "Ready to send to all users?"
    yn = $stdin.gets.chomp
    if yn == "y"
      puts "Preparing to send in 5 seconds..."
      sleep(5)
      puts "Sending newsletter..."
      User.send_all_newsletters(ENV["NLNAME"], ENV["NLSUBJECT"])
    else
      puts "Aborting."
    end
  end    
end