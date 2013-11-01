task :new_trial_group => :environment do
  group = Group.new
  group.token = SecureRandom::hex(8)
  group.skip_init = true
  group.save(validate: false)

  puts "http://www.metabright.com/g/trial?t=#{group.token}"
end