Given 'I have a citizen account' do
  @current_user = Factory(:citizen)
end

Given 'I am at the Home Page' do
  visit(root_url)
end

Given 'I am logged out' do
  delete "/session"
end

Given /^I am logged in as a (.*)$/ do |user_type|
  @current_user ||= Factory(user_type.to_sym)
  @current_user.approve! if @current_user.organization?
  @current_user.activate! unless @current_user.active?
  @user = @current_user
  visit(new_session_path)
  fill_in("email",    :with => @current_user.email)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end

Given /^I login as a (.*)$/ do |user_type|
  @current_user ||= Factory(user_type.to_sym)
  @current_user.approve! if @current_user.organization?
  @current_user.activate! unless @current_user.active?
  @user = @current_user
  fill_in("email",    :with => @current_user.email)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end
