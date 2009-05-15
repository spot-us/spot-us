require File.dirname(__FILE__) + '/../spec_helper'

include ActionController::UrlWriter

describe UsersController do
  it 'allows signup' do
    lambda do
      do_create
      response.should redirect_to(root_path)
      flash[:success].should_not be_blank
    end.should change(User, :count).by(1)
  end

  it 'requires email on signup' do
    lambda do
      do_create(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  describe "on POST to create with bad params" do
    before do
      Factory(:network)
      post :create, :user => {}
    end

    it "should render the new template" do
      response.should render_template('users/new.html.haml')
    end

    it "should have errors on the user" do
      assigns[:user].should_not be_nil
    end

    it "should render the new user view" do
      response.should render_template('users/new')
    end
  end

  describe "when creating a News Org user" do
    it "should render a needs approval message" do
      do_create(:type => 'Organization')
      flash[:success].should =~ /approval/
    end
  end

  describe "when creating a non news org user" do
    it "should automatically activate the user" do
      user = Factory(:citizen)
      user.stub!(:save).and_return(true)
      user.should_receive(:activate!)
      User.stub!(:new).and_return(user)
      do_create(:type => 'Citizen')
      flash[:success].should =~ /Welcome/
    end
  end

  def do_create(options = {})
    Factory(:network)
    post :create, :user => { :email      => 'quire@example.com',
                             :first_name => 'Quire',
                             :last_name  => 'User',
                             :type       => 'Citizen',
                             :password   => 'tester',
                             :password_confirmation => 'tester'}.merge(options)
  end

  describe "on GET to activate" do
    before do
      @user = Factory(:citizen)
    end

    it "should activate the user's account successfully" do
      do_activate
      response.should redirect_to(root_url)
    end

    it "should display an error when unable to locate user's activation code" do
      do_activate('invalid_code')
      flash[:error].should_not be_empty
    end

    it "should redirect to login page when unable to locate user's activation code" do
      do_activate('invalid_code')
      response.should redirect_to(new_session_url)
    end

    it "should log the user in on successful activation" do
      do_activate
      controller.should be_logged_in
    end

    it "should redirect to the stored location" do
      do_activate
      response.should redirect_to(root_url)
    end

    def do_activate(activation_code = nil)
      activation_code ||= @user.activation_code
      get :activate, :activation_code => activation_code
    end

  end

  describe "activation email" do
    route_matches('/user/activation_email', :get, :controller => 'users', :action => "activation_email")
    route_matches('/user/resend_activation', :post, :controller => 'users', :action => "resend_activation")

    before do
      @user = Factory(:citizen)
      Mailer.stub!(:deliver_activation_email)
    end

    it "should successfully render on GET" do
      get :activation_email
      response.should be_success
    end

    it "should post email address and redirect back or default" do
      do_resend_activation
      response.should be_redirect
    end

    it "should deliver the resend activation email" do
      Mailer.should_receive(:deliver_activation_email)
      do_resend_activation
    end

    it "should display a success flash message" do
      do_resend_activation
      flash[:success].should_not be_empty
    end

    it "should display an error flash message when email not found" do
      do_resend_activation('invalid@whateverz.com')
      flash[:error].should_not be_empty
    end

    def do_resend_activation(email = nil)
      email ||= @user.email
      post :resend_activation, :email => email
    end
  end

  describe "password" do
    route_matches('/user/password', :get, :controller => 'users', :action => 'password')
    route_matches('/user/reset_password', :put, :controller => 'users', :action => 'reset_password')

    before do
      @user = Factory(:citizen)
      Mailer.stub!(:deliver_reset_password)
    end

    it "should successfully render on GET" do
      get :password
      response.should be_success
    end

    describe "when email is found" do
      before do
        User.stub!(:find_by_email).and_return(@user)
      end

      it "should redirect to login" do
        do_reset_password
        response.should redirect_to(new_session_url)
      end

      it "should reset the password" do
        @user.should_receive(:reset_password!)
        do_reset_password
      end

      it "should display a flash success message" do
        do_reset_password
        flash[:success].should_not be_nil
      end
    end

    describe "when email is not found" do
      before do
        User.stub!(:find_by_email).and_return(nil)
      end

      it "should display a flash error message" do
        do_reset_password
        flash[:error].should_not be_nil
      end

      it "should re-render the password form" do
        do_reset_password
        response.should render_template('password')
      end
    end

    def do_reset_password
      put :reset_password, :email => @user.email
    end
  end
end
