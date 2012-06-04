ab_test "Motto" do
  description "Require a motto on jumpstart."
  alternatives true, false
  metrics :registration_email, :registration_facebook
end