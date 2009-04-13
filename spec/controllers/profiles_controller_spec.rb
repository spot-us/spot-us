require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  route_matches('/profiles/1', :get, :controller => 'profiles',
                                     :action     => 'show',
                                     :id         => '1')

  it "should successfully render GET show" do
    get :show, :id => Factory(:user).to_param
    response.should be_success
  end

  it "should redirect index" do
    get :index
    response.should be_redirect
  end

  describe "redirect_appropriately" do
    it "redirects logged in users to their profile" do
      controller.stubs(:logged_in?).returns(true)
      get :index
      response.should redirect_to(myspot_profile_path)
    end
    it "redirects non-logged in users to the home page" do
      controller.stubs(:logged_in?).returns(false)
      get :index
      response.should redirect_to(root_path)
    end
  end

end
