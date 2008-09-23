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

    describe "on GET to edit" do
      before do
        get :edit
      end

      it "should be successful" do
        response.should be_success
      end

      it "should render the edit profile form" do
        response.should render_template('edit')
      end

      it "should assign the profile for the form" do
        assigns[:profile].should_not be_nil
      end
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
