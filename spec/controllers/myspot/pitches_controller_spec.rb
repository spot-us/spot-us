require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::PitchesController do
  route_matches("/myspot/pitches", :get, :controller => "myspot/pitches", :action => "index")
  describe "on GET to index" do
    before do
      @user = Factory(:user)
      @pitches = [Factory(:pitch)]

      controller.stubs(:current_user).returns(@user)
      @user.stub!(:pitches).and_return(@pitches)

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

    it "should find the user's pitches" do
      @user.should_receive(:pitches).with().and_return(@pitches)
      do_index
    end

    it "should assign the pitches" do
      do_index
      assigns[:pitches].should == @pitches
    end

    def do_index
      get :index
    end
  end
end

