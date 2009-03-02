Given "A sfbay network exists" do
  Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
end

Given "A consumer protection topic exists" do
  Topic.create!(:name => 'Consumer protection')
end

Given /^I have created a "(.*)"$/ do |model_name|
  set_instance_variable(model_name, model_name.classify.constantize.create!(Factory(model_name.to_sym, :user => @user).attributes))
end

Given /^A "(.*)" exists$/ do |model_name| 
  set_instance_variable(model_name, model_name.classify.constantize.create!(Factory(model_name.to_sym).attributes))
end

Given /^A "(.*)" exists for the "(.*)"$/ do |child, parent|
  child.classify.constantize.create!(Factory(child.to_sym, parent.to_sym => get_instance_variable(parent)).attributes)
end

Given /^my current network is (.*?)$/i do |subdomain|
  network = Network.find_or_create_by_name(subdomain)
  instance_variable_set("@current_network", network)
end

Given /^I am at the "(.*?)" network page$/ do |subdomain|
  visit(root_url(:subdomain => subdomain))
end

Then /^I should see "(.*?)" not linked$/ do |text|
  response.body.should include(text)
  response.should_not have_tag("a", text)
end
