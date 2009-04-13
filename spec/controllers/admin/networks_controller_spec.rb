require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe Admin::NetworksController do

  before do
    login_as Factory(:admin)
    @network = Factory(:network)
  end

  it "should redirect to networks index upon successful creation" do
    # work around because resources_controller will make a new network
    controller.expects(:edit_admin_network_path).returns('/the correct url')
    post :create, :network => {:name => 'network-name', :display_name => 'display-name'}
    response.should redirect_to('http://test.host/the correct url')
  end

  it "should render the the new action upon unsuccessful creation" do
    post :create, :network => {:name => 'bogus ///'}
    response.should render_template('new')
  end

  it "should redirect to edit when putting to update" do
    put :update, :id => @network.id, :network => {:name => @network.name}
    response.should redirect_to(edit_admin_network_path(@network))
  end
end
