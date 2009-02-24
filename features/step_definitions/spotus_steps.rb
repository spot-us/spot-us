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

