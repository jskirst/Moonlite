ab_test "Countdown options" do
  description "Different countdown times on jumpstart page."
  alternatives 5, 10, 15
  metrics :signups
end