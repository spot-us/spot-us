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
end

Factory.define :pitch do |pitch|
  pitch.headline              "Headline"
  pitch.location              { LOCATIONS.first }
  pitch.requested_amount      100
  pitch.short_description     "lorem ipsum"
  pitch.extended_description  "lorem ipsum"
  pitch.delivery_description  "lorem ipsum"
  pitch.contract_agreement    "1"
end

