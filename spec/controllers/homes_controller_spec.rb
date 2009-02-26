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

end
