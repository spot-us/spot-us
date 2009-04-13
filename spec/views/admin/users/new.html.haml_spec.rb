require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/users/new.html.haml" do
  include UsersHelper
  
  before(:each) do
    @user = mock_model(User)
    @user.stub!(:new_record?).and_return(true)
    @user.stub!(:email).and_return("MyString")
    @user.stub!(:first_name).and_return("MyString")
    @user.stub!(:last_name).and_return("MyString")
    @user.stub!(:type).and_return("MyString")
    @user.stub!(:photo_file_name).and_return("MyString")
    @user.stub!(:photo_content_type).and_return("MyString")
    @user.stub!(:photo_file_size).and_return("1")
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

  it "should render new form" do
    render "/admin/users/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", admin_users_path) do
      with_tag("input#user_email[name=?]", "user[email]")
      with_tag("input#user_first_name[name=?]", "user[first_name]")
      with_tag("input#user_last_name[name=?]", "user[last_name]")
      with_tag("input#user_type[name=?]", "user[type]")
      with_tag("input#user_photo_file_name[name=?]", "user[photo_file_name]")
      with_tag("input#user_photo_content_type[name=?]", "user[photo_content_type]")
      with_tag("input#user_photo_file_size[name=?]", "user[photo_file_size]")
      with_tag("textarea#user_about_you[name=?]", "user[about_you]")
      with_tag("input#user_website[name=?]", "user[website]")
      with_tag("input#user_address1[name=?]", "user[address1]")
      with_tag("input#user_address2[name=?]", "user[address2]")
      with_tag("input#user_city[name=?]", "user[city]")
      with_tag("input#user_state[name=?]", "user[state]")
      with_tag("input#user_zip[name=?]", "user[zip]")
      with_tag("input#user_phone[name=?]", "user[phone]")
      with_tag("input#user_country[name=?]", "user[country]")
      with_tag("input#user_notify_tips[name=?]", "user[notify_tips]")
      with_tag("input#user_notify_pitches[name=?]", "user[notify_pitches]")
      with_tag("input#user_notify_stories[name=?]", "user[notify_stories]")
      with_tag("input#user_notify_spotus_news[name=?]", "user[notify_spotus_news]")
      with_tag("input#user_fact_check_interest[name=?]", "user[fact_check_interest]")
    end
  end
end


