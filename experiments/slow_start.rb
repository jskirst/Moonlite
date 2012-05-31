ab_test "Slow start" do
  description "From jumpstart either drop them onto challenge page first (slow start) or directly into the challenge."
  alternatives true, false
  metrics :engagement
end