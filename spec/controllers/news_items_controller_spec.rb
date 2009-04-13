require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NewsItemsController do

  route_matches('/news_items', :get, :controller => 'news_items',
                                     :action     => 'index')
  route_matches('/news_items/sort_options', :get, :controller => 'news_items',
                                                 :action     => 'sort_options')

  describe "on GET to index" do
    it "should be successful" do
      do_index
      response.should be_success
    end

    it "should render the index view" do
      do_index
      response.should render_template('index')
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
      controller.expects(:options_for_sorting)
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
      @pitch = active_pitch
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

  describe "#get_news_items" do
    before do
      controller.stubs(:params).returns({:news_item_type => 'pitches', :page => '1'})
      controller.stubs(:current_network).returns(Factory(:network))
      @with_sort = stub('with_sort')
      @paginate = []
      @by_network = stub('by_network', :paginate => @paginate)
      @exclude_type = stub('exclude_type', :by_network => @by_network)
      @with_sort.stub!(:exclude_type).and_return(@exclude_type)
      Pitch.stub!(:with_sort).and_return(@with_sort)
      NewsItem.stub!(:with_sort).and_return(@with_sort)
    end

    it "should default to pitches with an invalid type" do
      controller.stubs(:params).returns({:news_item_type => 'crazy_shit'})
      Pitch.should_receive(:with_sort).and_return(@with_sort)
      controller.send(:get_news_items)
    end

    it "should call with_sort on the passed in model" do
      Pitch.should_receive(:with_sort).and_return(@with_sort)
      @with_sort.should_receive(:exclude_type).and_return(@exclude_type)
      controller.send(:get_news_items)
    end

    it "should exclude stories" do
      Pitch.should_receive(:with_sort).and_return(@with_sort)
      @exclude_type.should_receive(:by_network).and_return(@by_network)
      controller.send(:get_news_items)
    end

    it "should call paginate on the collection" do
      @by_network.should_receive(:paginate).and_return(@paginate)
      controller.send(:get_news_items)
    end

    it "should assign a news_items instance variable" do
      controller.send(:get_news_items)
      controller.instance_variable_get(:@news_items).should_not be_nil
    end

    it "should use the by_network named scope" do
      Pitch.should_receive(:with_sort).and_return(@with_sort)
      controller.send(:get_news_items)
    end
  end

  describe "GET index" do
    it "should render XML" do
      get :index, :format => 'rss'
      response.content_type.should == 'application/rss+xml'
    end
  end
end
