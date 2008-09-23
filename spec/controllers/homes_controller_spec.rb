require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomesController do

  route_matches('/', :get, :controller => 'homes', :action => 'show')

  it "should successfully respond to GET show" do
    get :show
    response.should be_success
  end

end
