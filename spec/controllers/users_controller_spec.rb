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
      response.should render_template('create')
      flash[:success].should_not be_blank
    end.should change(User, :count).by(1)
  end

  it 'generates password on signup' do
    do_create
    assigns[:user].crypted_password.should_not be_blank
    User.find_by_email(assigns[:user].email).should == assigns[:user]
    response.should be_success
    response.should render_template('create')
    flash[:success].should_not be_blank
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

    it "should render the new session view" do
      response.should render_template('sessions/new')
    end
  end
  
  def do_create(options = {})
    post :create, :user => { :email      => 'quire@example.com',
                             :first_name => 'Quire',
                             :last_name  => 'User',
                             :type       => 'Citizen' }.merge(options)
  end
end
