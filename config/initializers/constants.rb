USERNAME_ADJS = %w[aged ancient autumn billowing bitter black blue bold broken cold cool crimson damp dark dawn delicate divine dry empty falling floral fragrant frosty green hidden holy icy late lingering little lively long misty morning muddy nameless old patient polished proud purple quiet red restless rough shy silent small snowy solitary sparkling spring still summer throbbing twilight wandering weathered white wild winter wispy withered young]
USERNAME_NOUNS = %w[bird breeze brook bush butterfly cherry cloud darkness dawn dew dream dust feather field fire firefly flower fog forest frog frost glade glitter grass haze hill lake leaf meadow moon morning mountain night paper pine pond rain resonance river sea shadow shape silence sky smoke snow snowflake sound star sun sun sunset surf thunder tree violet voice water water waterfall wave wildflower wind wood]

STREAK_BONUSES = {
  3 => [0.25, "Heating Up"],
  5 => [0.5, "On Fire"],
  7 => [0.75, "Brilliant"],
  10 => [1.0, "Heating Up"],
  14 => [2.0, "Heating Up"],
  18 => [3.0, "Heating Up"],
  22 => [4.0, "Heating Up"],
  25 => [5.0, "Heating Up"],
  28 => [6.0, "Heating Up"],
  40 => [7.0, "Heating Up"]
}

POINT_LEVELS = []

level = 1
(1..1000000).each do |i|
  if i < 200
    current_level = 1
  else
    current_level = current_level.to_f
    current_level = (i.to_f**0.55) / Math.log(i)
    current_level = current_level - (current_level % 1)
    current_level = (current_level - 3).to_i
  end
  
  if current_level > level
    POINT_LEVELS << [current_level, i]
    level = current_level
  end
end

# URLS

LIGHT_BULB_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/Lightbulb+icon"

STONEY_SMALL_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
STONEY_MEDIUM_URL = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney_50x66.png"

ICON_CLOSE_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/close_icon.png"
ICON_CAMERA_URL   = "https://s3-us-west-1.amazonaws.com/moonlite/static/image.png"
ICON_LOADING_URL  = "https://s3-us-west-1.amazonaws.com/moonlite/static/loading.gif"
ICON_CHECK_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/circle_check_clip.png"
ICON_UPVOTE_URL   = "https://s3.amazonaws.com/moonlite-nsdub/static/purple+upvote+arrow.png"
ICON_DIVIDER_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/divider.png"

ICON_LOGIN_GOOGLE = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+google.png"
ICON_LOGIN_FACEBOOK = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+facebook.png"

ICON_CAROUSEL_LEFT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_left_light.png"
ICON_CAROUSEL_RIGHT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_right_light.png"

