topics = [
  "Gov't + Politics",
  "Local Science & Business",
  "Race & Demographics",
  "Education",
  "Consumer Protection",
  "Employment Issues",
  "Media Accountability",
  "Criminal Justice",
  "Wealth & Poverty",
  "Cultural Diversity",
  "Public Health",
  "Environment",
  "City Infrastructure"
]

topics.each { |t| Topic.create_or_update :name => t }
