require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do

  describe "on POST to create with a bad login" do
    before do
      post :create, :email => 'dontexist@example.com'
    end

    it "should assign a new user for the view" do
      assigns[:user].should_not be_nil
    end

    it "should be successful" do
      response.should be_success
    end
  end

  it 'assigns a user for the new user form' do
    get :new
    response.should be_success
    assigns[:user].should_not be_nil
  end

  it 'logins and redirects' do
    Factory(:user, :email => 'user@example.com', :password => 'test')
    post :create, :email => 'user@example.com', :password => 'test'
    session[:user_id].should_not be_nil
    response.should be_redirect
  end
  
  it "should create a donation for non-logged in user" do
    user = Factory(:user, :email => 'user@example.com', :password => 'test')
    donations = mock(:donations)
    user.stub!(:donations).and_return(donations)
    User.stub!(:authenticate).and_return(user)
    donations.should_receive(:create).with(:pitch_id=>1, :amount=>25)
    session[:news_item_id] = 1
    post :create, :email => 'user@example.com', :password => 'test'
  end
  
  it 'fails login and does not redirect' do
    Factory(:user, :email => 'user@example.com', :password => 'test')
    post :create, :email => 'user@example.com', :password => 'bad password'
    session[:user_id].should be_nil
    response.should be_success
  end

  it 'logs out' do
    login_as Factory(:user)
    get :destroy
    session[:user_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    Factory(:user, :email => 'user@example.com', :password => 'test')
    post :create, :email => 'user@example.com', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    Factory(:user, :email => 'user@example.com', :password => 'test')
    post :create, :email => 'user@example.com', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as Factory(:user)
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'logs in with cookie' do
    user = Factory(:user)
    user.remember_me
    request.cookies["auth_token"] = cookie_for(user)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    user = Factory(:user)
    user.remember_me
    user.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(user)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    user = Factory(:user)
    user.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token user.remember_token
  end
end
