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
  news_item.association(:user)
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
  pitch.association(:user)
end

Factory.define :affiliation do |donation|
  donation.association(:tip)
  donation.association(:pitch)
end

Factory.define :donation do |donation|
  donation.association(:user)
  donation.association(:pitch)
  donation.amount 42
end

Factory.define :tip do |tip|
  tip.headline               "Headline"
  tip.location               { LOCATIONS.first }
  tip.short_description      "lorem ipsum"
  tip.keywords               "lorem ipsum"
  tip.pledge_amount          100
  tip.association(:user)
end

Factory.define :pledge do |pledge|
  pledge.association(:user)
  pledge.association(:tip)
  pledge.amount 42
end

Factory.define :purchase do |purchase|
  purchase.first_name 'John'
  purchase.last_name  'User'
  purchase.address1   '100 Happy Lane'
  purchase.address2   'Apt. 2'
  purchase.city       'Boston'
  purchase.state      'MA'
  purchase.zip        '02141'

  purchase.association :user
  purchase.credit_card_number '1'
  purchase.credit_card_month '1'
  purchase.credit_card_type  'bogus'
  purchase.credit_card_year { Time.now.year + 1 }
  purchase.verification_value '111'
end

Factory.define :credit_card, :class => ActiveMerchant::Billing::CreditCard do |cc|
  cc.first_name         'Billy'
  cc.last_name          'Joel'
  cc.number             '1'
  cc.month              '1'
  cc.year               { Time.now.year + 1 }
  cc.verification_value '111'
  cc.add_attribute(:type, 'bogus')
end

def upload_fixture_file
  ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, *%w(spec fixtures upload_file.jpg)), "image/jpg", true)
end
