Given 'I have a citizen account' do
  @user = Factory(:citizen)
end

Given 'I am at the Home Page' do
  visit(root_url)
end

Given 'I am logged out' do
  delete "/session"
end

Given /^I am logged in as a "(.*)"$/ do |model_name|
  @user ||= Factory(model_name.to_sym)
  @user.activate! unless @user.active?
  visit(new_session_path)
  fill_in("email",    :with => @user.email)
  fill_in("password", :with => @user.password)
  click_button("Login")
end
