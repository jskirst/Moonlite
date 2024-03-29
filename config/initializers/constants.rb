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

# URLS

METABRIGHT_LOGO = "https://s3.amazonaws.com/moonlite-nsdub/static/MetaBrightLogo.png"
METABRIGHT_LOGO_200 = "https://s3.amazonaws.com/moonlite-nsdub/static/MB+logo+200+wide.png"

LIGHT_BULB_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/Lightbulb+icon"

STONEY_SMALL_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
STONEY_MEDIUM_URL = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney_50x66.png"
GIANT_STONEY      = "https://s3.amazonaws.com/moonlite-nsdub/static/GiantStoney.png"

ICON_DEFAULT_PROFILE = "https://s3-us-west-1.amazonaws.com/moonlite/static/default_profile_pic.png"
ICON_DEFAULT_PATH = "https://s3.amazonaws.com/moonlite-nsdub/static/random+pics/handshake.png"
ICON_CLOSE_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/close_icon.png"
ICON_CAMERA_URL   = "https://s3-us-west-1.amazonaws.com/moonlite/static/image.png"
ICON_LOADING_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/loading.gif"
ICON_CHECK_URL    = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/circle_check_clip.png"
ICON_UPVOTE_URL   = "https://s3.amazonaws.com/moonlite-nsdub/static/purple+upvote+arrow.png"
ICON_DIVIDER_URL  = "https://s3.amazonaws.com/moonlite-nsdub/static/divider.png"
ICON_NOTIFICATIONS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/notifications3_gray.png"
ICON_GEAR = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/gear_gray.png"

# These are the old navbar icons that are white
# ICON_NOTIFICATIONS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/notifications3.png"
# ICON_GEAR = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/gear.png"

ICON_BADGE_1      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_yellow.png"
ICON_BADGE_2      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_pink.png"
ICON_BADGE_3      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_lime.png"
ICON_BADGE_4      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_orange.png"
ICON_BADGE_5      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_magenta.png"
ICON_BADGE_6      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_blue.png"
ICON_BADGE_7      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_green.png"
ICON_BADGE_8      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_red.png"
ICON_BADGE_9      = "https://s3.amazonaws.com/moonlite-nsdub/static/Badges/star_black.png"

EVENT_ICON_WELCOME = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_new_user.png"
EVENT_ICON_VOTE = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_thumbs_up.png"
EVENT_ICON_COMMENT = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_comment.png"
EVENT_ICON_EDIT = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_edit.png"
EVENT_ICON_ACHIEVEMENT = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_achievement.png"
EVENT_ICON_ANNOUNCEMENT = "https://s3.amazonaws.com/moonlite-nsdub/static/Event+Icons/event_icon_new_path.png"

ICON_LOGIN_GOOGLE = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+google.png"
ICON_LOGIN_FACEBOOK = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+facebook.png"
ICON_LOGIN_LINKEDIN = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+linkedin.png"
ICON_LOGIN_GITHUB = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+github.png"

SHARE_FACEBOOK = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+Facebook+small.png"
SHARE_TWITTER = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+twitter+small.png"
SHARE_GOOGLE = "https://s3.amazonaws.com/moonlite-nsdub/static/icon+Google%2B+small.png"
SHARE_REDDIT = "https://s3.amazonaws.com/moonlite-nsdub/static/icon%2Breddit%2Bsmall.png"
SHARE_FACEBOOK_BIG = "https://s3.amazonaws.com/moonlite-nsdub/static/new+social+icons/icon_facebook_circle.png"
SHARE_GOOGLE_BIG = "https://s3.amazonaws.com/moonlite-nsdub/static/new+social+icons/icon_plus_circle.png"
SHARE_TWITTER_BIG = "https://s3.amazonaws.com/moonlite-nsdub/static/new+social+icons/icon_twitter_circle.png"

ICON_CAROUSEL_LEFT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_left_light.png"
ICON_CAROUSEL_RIGHT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/arrow_angle_right_light.png"

ICON_NEW_CHALLENGE = "https://s3-us-west-1.amazonaws.com/moonlite/static/Plus_sign.png"

STATIC_DIVIDER = "https://s3.amazonaws.com/moonlite-nsdub/static/divider.png"
IMAGE_PLACEHOLDER = "https://s3-us-west-1.amazonaws.com/moonlite/static/image_thumb.png"
YOUTUBE_PLACEHOLDER = "https://s3-us-west-1.amazonaws.com/moonlite/static/youtube_thumb.jpg"

NAVBAR_HOME = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/home_gray.png"
NAVBAR_EXPLORE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/explore_signpost_gray.png"
NAVBAR_PROFILE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/profile_gray.png"
NAVBAR_CREATE = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/create_gray.png"
NAVBAR_SEARCH = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/icon_search.png"
NAVBAR_ACCOUNT = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/icon_group.png"
NAVBAR_CHALLENGES = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/icon_challenges.png"
NAVBAR_EVALUATIONS = "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/icon_evaluator.png"
NAVBAR_VERTICAL_DOTS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/vertical_dots_gray.png"

# These are the old navbar icons that are white
# NAVBAR_SEARCH = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/search.png"
# NAVBAR_ACCOUNT = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/account.png"
# NAVBAR_CHALLENGES = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/challenges.png"
# NAVBAR_EVALUATIONS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/evaluations.png"
# NAVBAR_VERTICAL_DOTS = "https://s3.amazonaws.com/moonlite-nsdub/static/nav+bar+icons/vertical_dots.png"

CHALLENGE_IMAGE_STRATEGY = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/strategy_chess.png"
CHALLENGE_IMAGE_CODE = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/code.png"
CHALLENGE_IMAGE_FINANCE = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/finance.png"
CHALLENGE_IMAGE_NETWORKING = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/networking.png"
CHALLENGE_IMAGE_SALES = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/sales.png"
CHALLENGE_IMAGE_WRITING = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/writing.png"
CHALLENGE_IMAGE_GENERIC1 = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/rocket.png"
CHALLENGE_IMAGE_GENERIC2 = "https://s3.amazonaws.com/moonlite-nsdub/static/Challenge+Images/mountain.png"