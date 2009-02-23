require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomesController do

  route_matches('/', :get, :controller => 'homes', :action => 'show')

  describe "on GET to show" do
    before do
      @pitch = Factory(:pitch)
      @featured = stub('featured scope', :first => @pitch)
      @by_network = stub('by_network scope', :featured => @featured)
      Pitch.stub!(:by_network).and_return(@by_network)
      @network = stub('network')
      controller.stub!(:current_network).and_return(@network)
    end

    it "should be successful" do
      do_show
      response.should be_success
    end

    it "should ask for pitches in the network" do
      Pitch.should_receive(:by_network).with(@network).and_return(@by_network)
      do_show
    end

    it "should ask for featured pitches" do
      @by_network.should_receive(:featured).and_return(@featured)
      do_show
    end

    it "should pick the first one returned" do
      @featured.should_receive(:first).and_return(@pitch)
      do_show
    end

    it "should assign the featured pitch" do
      do_show
      assigns[:featured_pitch].should == @pitch
    end

    def do_show
      get :show
    end
  end

end
