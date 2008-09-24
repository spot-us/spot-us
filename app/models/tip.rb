class Tip < NewsItem
  validates_presence_of :short_description
  validates_presence_of :keywords

  validates_inclusion_of :location, :in => LOCATIONS
end
