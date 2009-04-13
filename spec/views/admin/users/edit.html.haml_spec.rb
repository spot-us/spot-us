require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/users/edit.html.erb" do
  include UsersHelper
  
  before do
    @user = mock_model(User)
    @user.stub!(:email).and_return("MyString")
    @user.stub!(:first_name).and_return("MyString")
    @user.stub!(:last_name).and_return("MyString")
    @user.stub!(:organization_name).and_return("MyString")
    @user.stub!(:established_year).and_return("MyString")
    @user.stub!(:type).and_return("MyString")
    @user.stub!(:about_you).and_return("MyText")
    @user.stub!(:website).and_return("MyString")
    @user.stub!(:address1).and_return("MyString")
    @user.stub!(:address2).and_return("MyString")
    @user.stub!(:city).and_return("MyString")
    @user.stub!(:state).and_return("MyString")
    @user.stub!(:zip).and_return("MyString")
    @user.stub!(:phone).and_return("MyString")
    @user.stub!(:country).and_return("MyString")
    @user.stub!(:notify_tips).and_return(false)
    @user.stub!(:notify_pitches).and_return(false)
    @user.stub!(:notify_stories).and_return(false)
    @user.stub!(:notify_spotus_news).and_return(false)
    @user.stub!(:fact_check_interest).and_return(false)
    @user.stub!(:network).and_return(Factory(:network))
    @user.stub!(:network_id).and_return("MyString")
    @user.stub!(:category).and_return(Factory(:category))
    @user.stub!(:category_id).and_return("MyString")
    assigns[:user] = @user
  end

  it "should render edit form" do
    render "/admin/users/edit.html.erb"
    
    response.should have_tag("form[action=#{admin_user_path(@user)}][method=post]") do
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_first_name[name=?]', "user[first_name]")
      with_tag('input#user_last_name[name=?]', "user[last_name]")
      with_tag('input#user_organization_name[name=?]', "user[organization_name]")
      with_tag('input#user_established_year[name=?]', "user[established_year]")
      with_tag('input#user_type[name=?]', "user[type]")
      with_tag('textarea#user_about_you[name=?]', "user[about_you]")
      with_tag('input#user_website[name=?]', "user[website]")
      with_tag('input#user_address1[name=?]', "user[address1]")
      with_tag('input#user_address2[name=?]', "user[address2]")
      with_tag('input#user_city[name=?]', "user[city]")
      with_tag('input#user_state[name=?]', "user[state]")
      with_tag('input#user_zip[name=?]', "user[zip]")
      with_tag('input#user_phone[name=?]', "user[phone]")
      with_tag('input#user_country[name=?]', "user[country]")
      with_tag('input#user_notify_tips[name=?]', "user[notify_tips]")
      with_tag('input#user_notify_pitches[name=?]', "user[notify_pitches]")
      with_tag('input#user_notify_stories[name=?]', "user[notify_stories]")
      with_tag('input#user_notify_spotus_news[name=?]', "user[notify_spotus_news]")
      with_tag('input#user_fact_check_interest[name=?]', "user[fact_check_interest]")
    end
  end
end


