require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::DonationAmountsController do

  route_matches('/myspot/donations/amounts/edit', 
                :get, 
                :controller => 'myspot/donation_amounts',
                :action     => 'edit')

  route_matches('/myspot/donations/amounts', 
                :put, 
                :controller => 'myspot/donation_amounts',
                :action     => 'update')

  describe "when logged in with donations" do
    before do
      @user = Factory(:user)
      @donations = [Factory(:donation, :user => @user, :paid => false),
                    Factory(:donation, :user => @user, :paid => false)]
      login_as @user
    end

    describe "on GET to edit" do
      before do
        controller.stub!(:current_user).and_return(@user)
        @user.stub!(:donations).and_return(@donations)
        @donations.stub!(:unpaid).and_return(@donations)
      end

      it "should be successful" do
        do_edit
        response.should be_success
      end

      it "should find the logged in user" do
        controller.should_receive(:current_user).at_least(1).with().and_return(@user)
        do_edit
      end

      it "should render the edit view" do
        do_edit
        response.should render_template('edit')
      end

      it "should find the user's donations" do
        @user.should_receive(:donations).with().and_return(@donations)
        do_edit
      end

      it "should assign the user for the view" do
        do_edit
        assigns[:user].should_not be_blank
      end

      it "should only find unpaid donations" do
        @donations.should_receive(:unpaid).with().and_return(@donations)
        do_edit
      end

      def do_edit
        get :edit
      end
    end

    describe "on PUT to update with valid input" do
      it "should redirect to the new purchase page" do
        do_update
        response.should redirect_to(new_myspot_purchase_path)
      end

      it "should update the donation amounts" do
        do_update
        @donations.first.reload
        @donations.first.amount.should == '100.0'
      end

      def do_update
        put :update, { :user => { :donation_amounts => { @donations.first.to_param => 100 } } }
      end
    end

    describe "on PUT to update with invalid input" do
      it "render the edit view" do
        do_update
        response.should render_template('edit')
      end

      it "should not update the donation amounts" do
        lambda { do_update }.should_not change { @donations.first.amount }
      end

      it "should assign donations for the view" do
        do_update
        assigns[:donations].should_not be_blank
      end

      it "should assign the user for the view" do
        do_update
        assigns[:user].should_not be_blank
      end

      def do_update
        put :update, { :user => { :donation_amounts => { @donations.first.to_param => nil } } }
        @donations.first.reload
      end
    end
  end

  requires_login_for :get, :edit
  requires_login_for :put, :update

end
