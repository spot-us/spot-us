require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DonationsController do
  describe "on GET to /donations" do
    it "returns only unpaid donations" do
      user = Factory(:user)
      controller.should_receive(:current_user).and_return(user)
      donations = []
      donations.should_receive(:unpaid).and_return([:donation])
      user.should_receive(:donations).and_return(donations)
      get :index
      assigns(:donations).should == [:donation]
    end
  end
end
