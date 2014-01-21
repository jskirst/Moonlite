task :run_tests do
  system "rspec spec/models"
  system "rspec spec/helpers"
  system "rspec spec/requests/admin_spec.rb"
  system "rspec spec/requests/challenge_spec.rb"
  system "rspec spec/requests/custom_styles_spec.rb"
  system "rspec spec/requests/editor_spec.rb"
  system "rspec spec/requests/labs_spec.rb"
  system "rspec spec/requests/password_reset_spec.rb"
  system "rspec spec/requests/registration_spec.rb"
  system "rspec spec/requests/group_functions_spec.rb"
end