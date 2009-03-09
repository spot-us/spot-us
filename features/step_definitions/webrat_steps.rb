# Commonly used webrat steps
# http://github.com/brynary/webrat

When /^I press "(.*)"$/ do |button|
  click_button(button)
end

When /^I follow "(.*)"$/ do |link|
  click_link(link)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  fill_in(field, :with => value)
end

When /^I select "(.*)" from "(.*)"$/ do |value, field|
  webrat_session.select(value, :from => field)
end

# Use this step in conjunction with Rail's datetime_select helper. For example:
# When I select "December 25, 2008 10:00" as the date and time
When /^I select "(.*)" as the date and time$/ do |time|
  select_datetime(time)
end

# Use this step when using multiple datetime_select helpers on a page or
# you want to specify which datetime to select. Given the following view:
#   <%= f.label :preferred %><br />
#   <%= f.datetime_select :preferred %>
#   <%= f.label :alternative %><br />
#   <%= f.datetime_select :alternative %>
# The following steps would fill out the form:
# When I select "November 23, 2004 11:20" as the "Preferred" data and time
# And I select "November 25, 2004 10:30" as the "Alternative" data and time
When /^I select "(.*)" as the "(.*)" date and time$/ do |datetime, datetime_label|
  select_datetime(datetime, :from => datetime_label)
end

# Use this step in conjuction with Rail's time_select helper. For example:
# When I select "2:20PM" as the time
# Note: Rail's default time helper provides 24-hour time-- not 12 hour time. Webrat
# will convert the 2:20PM to 14:20 and then select it.
When /^I select "(.*)" as the time$/ do |time|
  select_time(time)
end

# Use this step when using multiple time_select helpers on a page or you want to
# specify the name of the time on the form.  For example:
# When I select "7:30AM" as the "Gym" time
When /^I select "(.*)" as the "(.*)" time$/ do |time, time_label|
  select_time(time, :from => time_label)
end

# Use this step in conjuction with Rail's date_select helper.  For example:
# When I select "February 20, 1981" as the date
When /^I select "(.*)" as the date$/ do |date|
  select_date(date)
end

# Use this step when using multiple date_select helpers on one page or
# you want to specify the name of the date on the form. For example:
# When I select "April 26, 1982" as the "Date of Birth" date
When /^I select "(.*)" as the "(.*)" date$/ do |date, date_label|
  select_date(date, :from => date_label)
end

When /^I check "(.*)"$/ do |field|
  check(field)
end

When /^I uncheck "(.*)"$/ do |field|
  uncheck(field)
end

When /^I choose "(.*)"$/ do |field|
  choose(field)
end

When /^I attach the file at "(.*)" to "(.*)" $/ do |path, field|
  attach_file(field, path)
end

Then /^I should see "(.*)"$/ do |text|
  current_dom.inner_text.should include_text(text)
end

Then /^I should see a tag of "(.*)" with "(.*)"$/ do |tag, text|
  response.should have_tag(tag, /#{text}/i)
end

Then /^I should see an? "(.*)" link$/ do |text|
  response.should(have_tag("a", /#{text}/i))
end

Then /^I should see an? "(.*)" titled link$/ do |text|
  response.should have_tag("a[title=?]", text)
end

Then /^I should not see an? "(.*)" titled link$/ do |text|
  response.should_not have_tag("a[title=?]", text)
end

Then /^I should see a Show\/Hide handle$/ do
  response.should have_tag("a[class*=?]", "open-close")
end


Then /^I should see an? "(.*)" action$/ do |text|
  response.should have_tag("a[class*=?]", /#{text.parameterize.wrapped_string}/)
end

Then /^I should not see an? "(.*)" link$/ do |text|
  response.should_not have_tag("a", text)
end

Then /^I should see an? "(.*)" link to "(.*)"$/ do |text, href|
  response.should have_tag("a[href=?]", href, text)
end

Then /^I should not see an? "(.*)" link to "(.*)"$/ do |text, href|
  response.should_not have_tag("a[href=?]", href, text)
end

Then /^I should see "(.*)" inside a text field$/ do |text|
  current_dom.should have_tag('input[type=text][value=?]', text)
end

Then /^I should not see "(.*)"$/ do |text|
  current_dom.inner_text.should_not include_text(text)
end

Then /^I should see an? "(.*)" text field$/ do |field_name|
  response.should have_tag('input[type=text][name*=?]', /#{field_name}/i)
end

Then /^I should see an? "(.*)" check box$/ do |field_name|
  response.should have_tag('input[type=checkbox][name*=?]', /#{field_name}/i)
end

Then /^I should see a "(.*)" dropdown$/ do |text|
  response.should have_tag("select option", text)
end

Then /^I should not see a "(.*)" dropdown$/ do |text|
  response.should_not have_tag("select option", text)
end

Then /^the "(.*)" checkbox should be checked$/ do |label|
  field_labeled(label).should be_checked
end

When /^I visit the ([\w -]+?) ?page$/ do |name|
  visit(human_route(name))
end

When /^I view the current ([\w -]+?) ?page$/ do |name|
  visit(human_route_for_current(name))
end

Then /^I should be on the (.*?) page$/ do |path|
  action, controller = path.split(/\s/)
  controller.gsub!('::', '/')
  response.should render_template("#{controller.pluralize}/#{action}")
end

Given /^I am on the (.*)$/ do |fragment|
  When "I visit the #{fragment}"
end

When /^I save the form$/ do
  When 'I press "Submit"'
end

Given /^I am at the new blog post page for my pitch$/ do
  visit(new_pitch_post_path(@pitch))
end
