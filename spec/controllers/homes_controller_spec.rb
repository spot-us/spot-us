require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomesController do

  route_matches('/', :get, :controller => 'homes', :action => 'show')

  describe "on GET to show" do
    before do
      @pitches = [Factory(:pitch)]
      Pitch.stub!(:featured_by_network).and_return(@pitches)
    end

    it "should be successful" do
      do_show
      response.should be_success
    end

    it "should ask for featured pitches" do
      Pitch.should_receive(:featured_by_network).and_return(@pitches)
      do_show
    end

    it "should assign the featured pitches" do
      do_show
      assigns[:featured].should == @pitches
    end

    def do_show
      get :show
    end
  end

  describe "on GET to start_story" do
    it 'redirects to login' do
      get :start_story
      response.should redirect_to(new_session_path)
    end

    describe "for logged in reporters" do
      before do
        @reporter = Factory(:reporter)
        controller.stubs(:logged_in?).returns(true)
        controller.stubs(:current_user).returns(@reporter)
      end

      it 'redirects to new_pitch_path' do
        get :start_story
        response.should redirect_to(new_pitch_path)
      end
    end

    describe "for logged in citizens" do
      before do
        @citizen = Factory(:citizen)
        controller.stubs(:logged_in?).returns(true)
        controller.stubs(:current_user).returns(@citizen)
      end

      it 'redirects to new tip path' do
        get :start_story
        response.should redirect_to(new_tip_path)
      end
    end
  end

end
