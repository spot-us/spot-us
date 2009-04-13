require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::PledgesController do
  route_matches("/myspot/pledges", :get, :controller => "myspot/pledges", :action => "index")

  describe "on GET to index" do
    before do
      @user = Factory(:user)
      @pledges = [Factory(:pledge)]

      controller.stubs(:current_user).returns(@user)
      @user.stub!(:pledges).and_return(@pledges)

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
      controller.expects(:current_user).at_least(1).with().returns(@user)
      do_index
    end

    it "should find the user's pledges" do
      @user.should_receive(:pledges).with().and_return(@pledges)
      do_index
    end

    it "should assign the pledges" do
      do_index
      assigns[:pledges].should == @pledges
    end

    def do_index
      get :index
    end
  end
end

