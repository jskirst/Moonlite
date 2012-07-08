ab_test "Jump start immediate registration" do
  description "From jump start either drop them directly into the registration or onto challenge."
  alternatives true, false
  metrics :registration_email, :registration_facebook
end