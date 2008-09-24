Factory.sequence(:email) { |n| "email#{n}@example.com" }

Factory.define :user do |user|
  user.email { Factory.next(:email) }
  user.first_name 'Billy'
  user.last_name  'Joel'
  user.add_attribute(:type, 'Citizen')
end

Factory.define :news_item do |news_item|
  news_item.headline "Headline"
  news_item.location { LOCATIONS.first }
  news_item.featured_image_caption "lorem ipsum"
  news_item.featured_image  { upload_fixture_file }
end

Factory.define :pitch do |pitch|
  pitch.headline               "Headline"
  pitch.location               { LOCATIONS.first }
  pitch.requested_amount       100
  pitch.short_description      "lorem ipsum"
  pitch.extended_description   "lorem ipsum"
  pitch.delivery_description   "lorem ipsum"
  pitch.featured_image_caption "lorem ipsum"
  pitch.skills                 "lorem ipsum"
  pitch.keywords               "lorem ipsum"
  pitch.contract_agreement     "1"
  pitch.featured_image         { upload_fixture_file }
end

Factory.define :donation do |donation|
  donation.association(:user)
  donation.association(:pitch)
end

Factory.define :tip do |tip|
  tip.headline               "Headline"
  tip.location               { LOCATIONS.first }
  tip.short_description      "lorem ipsum"
  tip.keywords               "lorem ipsum"
end

def upload_fixture_file
  ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, *%w(spec fixtures upload_file.jpg)), "image/jpg", true)
end
