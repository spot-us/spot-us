require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::SettingsController do

  route_matches('/myspot/settings/edit', :get, :controller => 'myspot/settings',
                                               :action     => 'edit')

  route_matches('/myspot/settings', :put, :controller => 'myspot/settings',
                                          :action     => 'update')

  describe "when logged in" do
    before do
      @user = Factory(:user)
      login_as @user
    end

    it "should successfully GET edit" do
      get :edit
      response.should be_success
    end

    context "handling PUT update with valid input" do
      it "should change the user's email" do
        lambda { do_update }.should change { @user.email }
      end

      it "should redirect to the edit settings page" do
        do_update
        response.should redirect_to(edit_myspot_settings_path)
      end

      it "should set a flash message" do
        do_update
        flash[:success].should_not be_blank
      end

      def do_update
        put :update, :settings => { :email => 'new@example.com' }
        @user.reload
      end
    end

    context "handling PUT update with invalid input" do
      it "should not change the user's email" do
        lambda { do_update }.should_not change { @user.email }
      end

      it "render the edit view" do
        do_update
        response.should render_template('edit')
      end

      def do_update
        put :update, :settings => { :email => '' }
        @user.reload
      end
    end
  end

  describe "when not logged in" do
    before do
      login_as nil
    end

    requires_login_for :get, :edit
    requires_login_for :put, :update
  end

end
