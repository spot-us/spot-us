require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/users/show.html.erb" do
  include UsersHelper
  
  before(:each) do
    @user = mock_model(User)
    @user.stub!(:email).and_return("MyString")
    @user.stub!(:first_name).and_return("MyString")
    @user.stub!(:last_name).and_return("MyString")
    @user.stub!(:type).and_return("MyString")
    @user.stub!(:photo_file_name).and_return("MyString")
    @user.stub!(:photo_content_type).and_return("MyString")
    @user.stub!(:photo_file_size).and_return("1")
    @user.stub!(:location).and_return("MyString")
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

    assigns[:user] = @user
  end

  it "should render attributes in <p>" do
    render "/admin/users/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/als/)
    response.should have_text(/als/)
    response.should have_text(/als/)
    response.should have_text(/als/)
    response.should have_text(/als/)
  end
end

