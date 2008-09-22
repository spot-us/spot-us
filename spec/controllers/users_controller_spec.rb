require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper
include ActionController::UrlWriter

describe UsersController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it "routes /user to the 'show' action" do
    user_path.should == "/user"
  end

  it "routes /user to the 'show' action" do
    route_for(:controller => "users", :action => "show").should == "/user"
  end

  it 'generates password on signup' do
    create_user
    assigns[:user].password.should_not be_blank
    assigns[:user].password.size.should == 6
    User.authenticate(assigns[:user].email, assigns[:user].password).should == 
      assigns[:user]
    response.should be_redirect
  end
  
  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  
  def create_user(options = {})
    post :create, :user => { :email => 'quire@example.com' }.merge(options)
  end
end
