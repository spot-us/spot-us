require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewsItemsController do

  route_matches('/news_items', :get, :controller => 'news_items',
                                     :action     => 'index')
 route_matches('/news_items/sort_options', :get, :controller => 'news_items',
                                                 :action     => 'sort_options')

  describe "on GET to index" do
    before do
      @items = [Factory(:pitch)]
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
      @items.should_receive(:sorted).with('desc')
      Pitch.should_receive(:unpublished).and_return(@items)
      do_index
    end

    def do_index
      get :index
    end
  end
  
  describe "on GET to sort_options" do
    before(:each) do
      
    end
    def do_sort_options
      get :sort_options
    end
    it "should be successful" do
      do_sort_options
      response.should be_success
    end
    
    it "should call options_for_sorting" do
      controller.should_receive(:options_for_sorting)
      do_sort_options
    end
    
    it "should return a list of option elements" do
      do_sort_options
      response.should have_tag('option.news_items') 
    end
  end
  
  describe "on POST to search" do
    before do
      @tip = Factory(:tip)
      @pitch = Factory(:pitch)
      @items = [@tip, @pitch]
    end
    
    it "should return all tips and pitches in one collection when both sent" do
      post :search, :news_item_type => 'news_items'
      assigns[:news_items].should include(@tip)
      assigns[:news_items].should include(@pitch)
    end
    
    it "should only return tips when tips is requested" do
      post :search, :news_item_type => 'tips'
      assigns[:news_items].should == [@tip]
    end
    
    
    it "should only return pitches when pitches is requested" do
      post :search, :news_item_type => 'pitches'
      assigns[:news_items].should == [@pitch]
    end
    
    
    it "should display only and pitches when the input is empty" do
      post :search
      assigns[:news_items].should include(@pitch)
    end
  end
end
