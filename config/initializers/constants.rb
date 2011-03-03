LOCATIONS = [
  "Bay Area",
  "San Francisco",
  "North Bay",
  "Peninsula",
  "East Bay",
  "South Bay"
].freeze

MAIL_FROM_INFO = %("Spot.Us" <info@spot.us>)
MAIL_WEBMASTER = %("Webmaster Spot.Us" <webmaster@spot.us>)
PREPEND_STATUS_UPDATE = "Spot.Us"

MODEL_NAMES = {
  'suggested' => 'Tip',
  'unfunded' => 'Pitch',
  'almost-funded' => 'Pitch',
  'funded' => 'Pitch',
  'published' => 'Story'
}

FILTERS_STORIES = ActiveSupport::OrderedHash.new
FILTERS_STORIES["unfunded"]="Unfunded"
FILTERS_STORIES["almost-funded"]="Almost Funded"
FILTERS_STORIES["funded"]="Funded"
FILTERS_STORIES["published"]="Published"
FILTERS_STORIES["suggested"]="Suggested"
FILTERS_STORIES["updates"]="Updates"
FILTERS_STORIES["recent"]="Recent"
FILTERS_STORIES_STRING = FILTERS_STORIES.collect{ |key, value| key}.join('|')

FILTERS_CONTRIBUTORS = ActiveSupport::OrderedHash.new
FILTERS_CONTRIBUTORS["donated"]="Recently Donated"
FILTERS_CONTRIBUTORS["donated-most"]="Donated Most"
FILTERS_CONTRIBUTORS["organizations"]="Organizations"
FILTERS_CONTRIBUTORS["reporters"]="Reporters"
FILTERS_CONTRIBUTORS_STRING = FILTERS_CONTRIBUTORS.collect{ |key, value| key}.join('|')

TEXT = {}
TEXT[:headline] = "Write a short, enticing and descriptive headline"
TEXT[:title] = "Write a short, enticing and descriptive title"

SHOW_PREPEND_FOR_STORY_UPDATES = false