Factory.sequence(:email) { |n| "email#{n}@example.com" }

Factory.define :user do |user|
  user.email { Factory.next(:email) }
end

