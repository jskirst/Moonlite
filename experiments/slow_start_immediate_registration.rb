ab_test "Slow start immediate registration" do
  description "From slow start either drop them directly into the registration or onto challenge."
  alternatives true, false
  metrics :registration_email, :registration_facebook
end