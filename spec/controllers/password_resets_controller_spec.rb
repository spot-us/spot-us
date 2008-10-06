require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordResetsController do

  it "should route GET /password_reset/new to PasswordResetsController#new" do
    params_from(:get, '/password_reset/new').should == 
      { :controller => 'password_resets', :action => 'new' }
  end

  it "should route POST /password_reset to PasswordResetsController#create" do
    params_from(:post, '/password_reset').should == 
      { :controller => 'password_resets', :action => 'create' }
  end

  describe "handling GET new" do
    before do
      get :new
    end

    it "should be successful" do
      response.should be_success
    end

    it "should render the password reset form" do
      response.should render_template('password_resets/new')
    end

    it "should assign a user for the view" do
      assigns[:user].should_not be_nil
    end
  end

  describe "handling POST create for an existing email" do
    before do
      @random_email_address = random_email_address
      @user = Factory(:user, :email => @random_email_address)
      @old_crypted_password = @user.crypted_password
    end

    it "should redirect to the login page" do
      do_create
      response.should redirect_to(new_session_path)
    end

    it "should set a success flash message" do
      do_create
      flash[:success].should_not be_nil
    end

    it "should deliver a password reset email" do
      Mailer.should_receive(:deliver_password_reset_notification).once
      do_create
    end

    it "should reset the password" do
      do_create
      @user.reload
      @user.crypted_password.should_not == @old_crypted_password
    end

    def do_create
      post :create, :email => @random_email_address
    end
  end

  describe "handling POST create for a nonexisting email" do
    before do
      User.destroy_all
    end

    it "should set a flash error message" do
      do_create
      flash[:error].should_not be_blank
    end

    it "render the password reset page" do
      do_create
      response.should render_template('new')
    end

    it "should not deliver any emails" do
      Mailer.should_not_receive(:deliver_password_reset_notification)
      do_create
    end

    it "should assign a new user for the form" do
      do_create
      assigns[:user].should_not be_nil
    end

    def do_create
      post :create, :email => 'notreal@example.com'
    end
  end

end
