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
      NewsItem.should_receive(:find).with(:all, {:order=>"created_at desc"}).and_return(@items)
      do_index
    end

    def do_index
      get :index
    end
  end
  
  
  describe "on POST to search" do
    before do
      @tip = Factory(:tip)
      @pitch = Factory(:pitch)
      @items = [@tip, @pitch]
    end
    
    it "should return all tips and pitches in one collection when both sent" do
      post :search, :news_item_types => {:tip => "1", :pitch => "1"}
      assigns[:news_items].should include(@tip)
      assigns[:news_items].should include(@pitch)
    end
    
    it "should only return pitches when only pitches is requested" do
      post :search, :news_item_types => {:pitch => "1"}
      assigns[:news_items].should == [@pitch]
    end
    
    it "should display all tips and pitches when the input is empty" do
      post :search
      assigns[:news_items].should include(@tip)
      assigns[:news_items].should include(@pitch)
    end
  end
end
