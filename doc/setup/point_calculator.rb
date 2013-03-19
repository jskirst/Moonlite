multiplier = (ARGV[0] || 0.55).to_f
substractor = (ARGV[1] || 3).to_f
POINT_LEVELS = []

level = 1
(1..1000000).each do |i|
  if i < 200
    current_level = 1
  else
    current_level = current_level.to_f
    current_level = (i.to_f**multiplier) / Math.log(i)
    current_level = current_level - (current_level % 1)
    current_level = (current_level - substractor).to_i
  end
  
  if current_level > level
    POINT_LEVELS << [current_level, i]
    level = current_level
  end
end

puts POINT_LEVELS.to_s