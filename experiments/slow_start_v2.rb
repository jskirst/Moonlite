ab_test "Jump/slow start engagement" do
  description "From jumpstart either drop them onto challenge page first (slow start) or directly into the challenge."
  alternatives true, false
  metrics :registration_email, :registration_facebook
end