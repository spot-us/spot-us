require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  route_matches('/profiles/1', :get, :controller => 'profiles',
                                     :action     => 'show',
                                     :id         => '1')

  it "should successfully render GET show" do
    get :show, :id => Factory(:user).to_param
    response.should be_success
  end

end
