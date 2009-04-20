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

  it 'logs in and redirects' do
    Factory(:user, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test').activate!
    post :create, :email => 'user@example.com', :password => 'test'
    session[:user_id].should_not be_nil
    response.should redirect_to(root_path)
  end

  it "should create a donation for non-logged in user" do
    user = Factory(:user, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test')
    donations = mock(:donations)
    donations.stub!(:unpaid).and_return([])
    user.stub!(:donations).and_return(donations)
    User.stub!(:authenticate).and_return(user)
    donations.should_receive(:create).with(:pitch_id=>1, :amount=>25)
    session[:news_item_id] = 1
    session[:donation_amount] = 25
    post :create, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test'
  end

  it 'fails login and does not redirect' do
    Factory(:user, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test')
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
    Factory(:user, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test').activate!
    post :create, :email => 'user@example.com', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end

  it 'sets the current user full name cookie' do
    user = Factory(:user, :first_name => "Bob", :last_name => "Levine", :email => 'user@example.com', :password => 'test', :password_confirmation => 'test').activate!
    post :create, :email => 'user@example.com', :password => 'test'
    # ASK JACQUI
    response.cookies["current_user_full_name"].should == "Bob+Levine"
  end

  it 'clears the current user full name cookie when logging out' do
    user = Factory(:user, :first_name => "Bob", :last_name => "Levine", :email => 'user@example.com', :password => 'test', :password_confirmation => 'test')
    post :create, :email => 'user@example.com', :password => 'test'
    get :destroy
    response.cookies["current_user_full_name"].should be_nil
  end

  it 'clears the balance text cookie when logging out' do
    user = Factory(:user, :first_name => "Bob", :last_name => "Levine", :email => 'user@example.com', :password => 'test', :password_confirmation => 'test')
    post :create, :email => 'user@example.com', :password => 'test'
    get :destroy
    response.cookies["balance_text"].should be_nil
  end

  it 'does not remember me' do
    Factory(:user, :email => 'user@example.com', :password => 'test', :password_confirmation => 'test')
    post :create, :email => 'user@example.com', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as Factory(:user)
    get :destroy
    response.cookies["auth_token"].should be_nil
  end

  describe 'when logging in from cookie' do
    before do
      @user = Factory(:user)
      @user.remember_me
      cookies["auth_token"] = cookie_for(@user)
      controller.stubs(:render_to_string).returns("")
    end

    it 'logs in successfully' do
      get :new
      controller.send(:logged_in?).should be_true
    end

    it 'fails expired remember_token cookie' do
      @user.update_attribute :remember_token_expires_at, 5.minutes.ago
      get :new
      controller.send(:logged_in?).should_not be_true
    end

    it 'fails login' do
      cookies["auth_token"] = auth_token('invalid_auth_token')
      get :new
      controller.send(:logged_in?).should_not be_true
    end

    it 'should initialize the current_user_full_name cookie' do
      get :new
      controller.send(:logged_in?)
      response.cookies.should have_key('current_user_full_name')
    end

    it 'should initialize the balance_text cookie' do
      get :new
      controller.send(:logged_in?)
      response.cookies.should have_key('balance_text')
    end
  end

  describe 'sessions#show' do
    it 'redirects to sessions#new' do
      get :show
      response.should redirect_to(new_session_path)
    end
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token user.remember_token
  end
end
