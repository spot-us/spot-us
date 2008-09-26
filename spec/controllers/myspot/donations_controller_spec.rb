require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::DonationsController do
  route_matches("/myspot/donations", :get, :controller => "myspot/donations", :action => "index")

  describe "on GET to index" do
    before do
      @user = Factory(:user)
      @donations = [Factory(:donation)]

      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:donations).and_return(@donations)
      @donations.stub!(:paid).and_return(@donations)

      login_as @user
    end

    it "should response successfully" do
      do_index
      response.should be_success
    end

    it "should render the index view" do
      do_index
      response.should render_template('index')
    end

    it "should find the current user" do
      controller.should_receive(:current_user).at_least(1).with().and_return(@user)
      do_index
    end

    it "should find the user's donations" do
      @user.should_receive(:donations).with().and_return(@donations)
      do_index
    end

    it "should only find paid donations" do
      @donations.should_receive(:paid).with().and_return(@donations)
      do_index
    end

    it "should assign the donations" do
      do_index
      assigns[:donations].should == @donations
    end

    def do_index
      get :index
    end
  end
end
