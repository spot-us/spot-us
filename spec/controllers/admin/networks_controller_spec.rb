require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::NetworksController do

  before do
    login_as Factory(:admin)
    @network = Factory(:network)
  end

  it "should redirect to networks index upon successful creation" do
    # work around because resources_controller will make a new network
    controller.should_receive(:edit_admin_network_path).and_return('/the correct url')
    post :create, :network => {:name => 'network-name'}
    response.should redirect_to('http://test.host/the correct url')
  end

  it "should render the the new action upon unsuccessful creation" do
    post :create, :network => {:name => 'bogus ///'}
    response.should render_template('new')
  end
end
