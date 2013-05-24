USERNAME_ADJS = %w[aged ancient autumn billowing bitter black blue bold broken cold cool crimson damp dark dawn delicate divine dry empty falling floral fragrant frosty green hidden holy icy late lingering little lively long misty morning muddy nameless old patient polished proud purple quiet red restless shy silent small snowy solitary sparkling spring still summer twilight wandering weathered white wild winter wispy withered young]
USERNAME_NOUNS = %w[bird breeze brook bush butterfly cherry cloud darkness dawn dew dream dust feather field fire firefly flower fog forest frog frost glade glitter grass haze hill lake leaf meadow moon morning mountain night ninja paper pine pond rain resonance river sea shadow shape silence sky smoke snow snowflake sound star sun sun sunset surf thunder tree violet voice water water waterfall wave wildflower wind wood]

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
    current_level = (i.to_f**0.57) / Math.log(i)
    current_level = current_level - (current_level % 1)
    current_level = (current_level - 3).to_i
  end
  
  if current_level > level
    POINT_LEVELS << [current_level, i]
    level = current_level
  end
end

level = 1
(1..1000000).each do |i|
  if i < 200
    current_level = 1
  else
    current_level = current_level.to_f
    current_level = (i.to_f**0.57) / Math.log(i)
    current_level = current_level - (current_level % 1)
    current_level = (current_level - 3).to_i
  end
  
  if current_level > level
    POINT_LEVELS << [current_level, i]
    level = current_level
  end
end

PATH_AVERAGES = {}
Path.all.each do |path|
  cts = path.completed_tasks.where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
  enrollments = path.enrollments.where(total_points: 0).count
  stats = {
    tasks_attempted: (cts.count / (enrollments == 0 ? 1 : enrollments)),
    percent_correct: (cts.where("status_id = ?", Answer::CORRECT).count.to_f / cts.count),
    correct_points: (cts.where("status_id = ?", Answer::CORRECT).average(:points_awarded).to_f)
  }
  PATH_AVERAGES[path.id] = stats
end

# URLS

METABRIGHT_LOGO = "https://s3.amazonaws.com/moonlite-nsdub/static/MetaBrightLogo.png"
METABRIGHT_LOGO_200 = "https://s3.amazonaws.com/moonlite-nsdub/static/MB+logo+200+wide.png"

LIGHT_BULB_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/Lightbulb+icon"

STONEY_SMALL_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
STONEY_MEDIUM_URL = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney_50x66.png"
GIANT_STONEY       = "https://s3.amazonaws.com/moonlite-nsdub/static/GiantStoney.png"

ICON_DEFAULT_PROFILE = "https://s3-us-west-1.amazonaws.com/moonlite/static/default_profile_pic.png"
ICON_CLOSE_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/close_icon.png"
ICON_CAMERA_URL   = "https://s3-us-west-1.amazonaws.com/moonlite/static/image.png"
ICON_LOADING_URL  = "https://s3-us-west-1.amazonaws.com/moonlite/static/loading.gif"
ICON_CHECK_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/circle_check_clip.png"
ICON_UPVOTE_URL   = "https://s3.amazonaws.com/moonlite-nsdub/static/purple+upvote+arrow.png"
ICON_DIVIDER_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/divider.png"
ICON_LOADING      = "https://s3-us-west-1.amazonaws.com/moonlite/static/ajax-trial.gif"
ICON_NOTIFICATIONS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/notifications3.png"
ICON_GEAR = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/gear.png"

ICON_BADGE_1      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_yellow.png"
ICON_BADGE_2      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_pink.png"
ICON_BADGE_3      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_lime.png"
ICON_BADGE_4      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_orange.png"
ICON_BADGE_5      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_magenta.png"
ICON_BADGE_6      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_blue.png"
ICON_BADGE_7      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_green.png"
ICON_BADGE_8      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_red.png"
ICON_BADGE_9      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_black.png"


ICON_LOGIN_GOOGLE = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+google.png"
ICON_LOGIN_FACEBOOK = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+facebook.png"

SHARE_FACEBOOK = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+Facebook+small.png"
SHARE_TWITTER = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+twitter+small.png"
SHARE_GOOGLE = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+Google%2B+small.png"

ICON_CAROUSEL_LEFT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_left_light.png"
ICON_CAROUSEL_RIGHT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_right_light.png"

STATIC_DIVIDER = "https://s3.amazonaws.com/moonlite-nsdub/static/divider.png"
IMAGE_PLACEHOLDER = "https://s3-us-west-1.amazonaws.com/moonlite/static/image_thumb.png"
YOUTUBE_PLACEHOLDER = "https://s3-us-west-1.amazonaws.com/moonlite/static/youtube_thumb.jpg"

NAVBAR_HOME = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/home.png"
NAVBAR_EXPLORE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/explore+signpost.png"
NAVBAR_PROFILE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/profile.png"
NAVBAR_CREATE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/create.png"

