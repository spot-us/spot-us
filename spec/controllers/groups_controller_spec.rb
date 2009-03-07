require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupsController do
  route_matches('/groups', :get, :controller => 'groups', :action => 'index')
  route_matches('/groups/1', :get, :controller => 'groups', :action => 'show', :id => "1")

  it "shouldn't allow new" do
    get :new
    response.should redirect_to(root_path)
  end
  it "shouldn't allow create" do
    post :create, :id => Factory(:group).id
    response.should redirect_to(root_path)
  end
  it "shouldn't allow edit" do
    get :edit, :id => Factory(:group).id
    response.should redirect_to(root_path)
  end
  it "shouldn't allow update" do
    put :update, :id => Factory(:group).id
    response.should redirect_to(root_path)
  end
  it "shouldn't allow destroy" do
    delete :destroy, :id => Factory(:group).id
    response.should redirect_to(root_path)
  end
end
