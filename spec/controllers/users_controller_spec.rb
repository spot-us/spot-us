require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper
include ActionController::UrlWriter

describe UsersController do
  it 'allows signup' do
    lambda do
      do_create
      response.should be_success
      response.should render_template('new')
      flash[:success].should_not be_blank
    end.should change(User, :count).by(1)
  end

  it 'requires email on signup' do
    lambda do
      do_create(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  describe "on POST to create with bad params" do
    before do
      post :create, :user => {}
    end

    it "should be successful" do
      response.should be_success
    end

    it "should have errors on the user" do
      assigns[:user].should_not be_nil
    end

    it "should render the new user view" do
      response.should render_template('users/new')
    end
  end

  def do_create(options = {})
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

    def do_activate(activation_code = nil)
      activation_code ||= @user.activation_code
      get :activate, :activation_code => activation_code
    end

  end
end
