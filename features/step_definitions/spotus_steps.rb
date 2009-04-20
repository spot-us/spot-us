Given "A sfbay network exists" do
  Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
end

Given "A consumer protection topic exists" do
  Topic.create!(:name => 'Consumer protection')
end

Given /^I have created a "(.*)"$/ do |model_name|
  instance_variable_set("@#{model_name}", Factory(model_name.to_sym, :user => @current_user))
end

Given /^[Aa] (\w+)(?: exists)?$/ do |model_name|
  instance = Factory(model_name.to_sym)
  instance_variable_set("@#{model_name}", instance)
end

Given /^I call the (.*?) transition on the current (.*?)$/ do |transition, object|
  instance_variable_get("@#{object}").send("#{transition}!".to_sym)
end

Given /^A (\w+) exists for the (.*)$/ do |child, parent|
  instance = Factory(child.to_sym, parent.to_sym => instance_variable_get("@#{parent}"))
  instance_variable_set("@#{child}", instance)
end

Given /^my current network is (.*?)$/i do |subdomain|
  network = Network.find_or_create_by_name(subdomain)
  instance_variable_set("@current_network", network)
end

Given /^I am at the "(.*?)" network page$/ do |subdomain|
  visit(root_url(:subdomain => subdomain))
end

When /^I activate my account with email "(.*)"$/ do |email|
  u = User.find_by_email(email)
  visit(activate_url(u.activation_code))
end

Then /^I should see "(.*?)" not linked$/ do |text|
  response.body.should include(text)
  response.should_not have_tag("a", text)
end

Then /^I should see a dropdown named "(.*?)"$/ do |text|
  response.should have_tag('select[name=?]', text)
end

Then /^I should not see a dropdown named "(.*?)"$/ do |text|
  response.should_not have_tag('select[name=?]', text)
end

Then /^I should see a form identified by "(.*?)"$/ do |id|
  response.should have_tag("form##{id}")
end

Then /^I should see a form with class "(.*?)"$/ do |id|
  response.should have_tag("form.#{id}")
end

Then /^I should not see a form identified by "(.*?)"$/ do |id|
  response.should_not have_tag("form##{id}")
end
