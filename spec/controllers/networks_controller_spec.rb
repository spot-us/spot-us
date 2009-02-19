require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NetworksController do

  describe "GET categories" do
    def do_get
      get :categories, :id => 17
    end

    before do
      @categories = [Factory(:category)]
      Category.stub!(:find_all_by_network_id).and_return(@categories)
    end

    it "should return categories as json" do
      do_get
      response.body.should == @categories.to_json
    end

    it "should load all categories for the passed in network" do
      Category.should_receive(:find_all_by_network_id).with('17').and_return(@categories)
      do_get
    end
  end

end
