require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::ProfilesController do

  route_matches('/myspot/profile/edit', :get, :controller => 'myspot/profiles',
                                              :action     => 'edit')

  route_matches('/myspot/profile', :put, :controller => 'myspot/profiles',
                                         :action     => 'update')

  describe "when logged in" do
    before do
      login_as Factory(:user)
    end

    it "should successfully GET edit" do
      get :edit
      response.should be_success
    end

    it "should successfully PUT update" do
      put :update
      response.should be_redirect
    end

    it "should successfully GET show" do
      get :show
      response.should be_success
    end
  end

  describe "when not logged in" do
    before do
      login_as nil
    end

    requires_login_for :get, :edit
    requires_login_for :put, :update
    requires_login_for :get, :show
  end

end
