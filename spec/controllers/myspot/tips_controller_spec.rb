require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::TipsController do
  route_matches("/myspot/tips", :get, :controller => "myspot/tips", :action => "index")

  describe "on GET to index" do
    before do
      @user = Factory(:user)
      @tips = [Factory(:tip)]

      controller.stubs(:current_user).returns(@user)
      @user.stub!(:tips).and_return(@tips)

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

    it "should find the user's tips" do
      @user.should_receive(:tips).with().and_return(@tips)
      do_index
    end

    it "should assign the tips" do
      do_index
      assigns[:tips].should == @tips
    end

    def do_index
      get :index
    end
  end
end

