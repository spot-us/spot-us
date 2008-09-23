Factory.sequence(:email) { |n| "email#{n}@example.com" }

Factory.define :user do |user|
  user.email { Factory.next(:email) }
  user.first_name 'Billy'
  user.last_name  'Joel'
  user.add_attribute(:type, 'Citizen')
end

Factory.define :pitch do |pitch|
end

