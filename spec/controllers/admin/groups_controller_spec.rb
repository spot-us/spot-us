require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  route_matches('/admin/groups', :get, :controller => 'admin/groups', :action => 'index')

  before do
    controller.stub!(:current_user).and_return(Factory(:admin))
  end

  it 'redirects to login if not an admin' do
    controller.stub!(:current_user).and_return(Factory(:citizen))
    get :new
    response.should redirect_to(new_session_path)
  end

  it 'requires admin' do
    get :new
    response.should be_success
  end

  it 'redirects to index on successful group creation' do
    post :create, :group => { :name => 'Villains', :description => "We don't need no stinky spelling" }
    flash[:success].should == "Success!"
    response.should redirect_to(admin_groups_path)
  end

  it "re-renders the new form on failed group creation" do
    post :create, :group => { :name => '', :description => '' }
    response.should render_template('new')
  end
end

