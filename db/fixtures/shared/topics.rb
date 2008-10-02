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

topics.each_with_index { |t, i| Topic.create_or_update :id => i + 1, :name => t }
