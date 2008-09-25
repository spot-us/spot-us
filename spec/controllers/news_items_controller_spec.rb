require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewsItemsController do

  route_matches('/news_items', :get, :controller => 'news_items',
                                     :action     => 'index')

  describe "on GET to index" do
    before do
      @items = [Factory(:tip), Factory(:pitch)]
      NewsItem.stub!(:newest).and_return(@items)
    end

    it "should be successful" do
      do_index
      response.should be_success
    end

    it "should render the index view" do
      do_index
      response.should render_template('index')
    end

    it "should find the most recent news items" do
      NewsItem.should_receive(:newest).with().and_return(@items)
      do_index
    end

    def do_index
      get :index
    end
  end
end
