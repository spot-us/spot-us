require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomesController do

  route_matches('/', :get, :controller => 'homes', :action => 'show')

  describe "on GET to show" do
    before do
      @featured = Factory(:pitch)

      Pitch.stub!(:featured).and_return(@featured)
    end

    it "should be successful" do
      do_show
      response.should be_success
    end

    it "should find the featured pitch" do
      Pitch.should_receive(:featured).with().and_return(@featured)
      do_show
    end

    it "should assign the featured pitch" do
      do_show
      assigns[:featured_pitch].should == @featured
    end

    def do_show
      get :show
    end
  end

end
