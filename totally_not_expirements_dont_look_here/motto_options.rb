ab_test "Motto options" do
  description "Display or don't display the option to set a motto on jumpstart page."
  alternatives true, false
  metrics :signups
end