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

  describe "#get_news_items" do
    before do
      controller.stub!(:params).and_return({:news_item_type => 'pitch', :page => '1'})
    end
    it "should raise an error if the passed in type is not valid" do
      controller.stub!(:params).and_return({:news_item_type => 'crazy_shit'})
      lambda do
        controller.send(:get_news_items)
      end.should raise_error("Can only search for valid news item types")
    end
    it "should call sort_by on the passed in model" do
      named_scope = stub(:paginate => [])
      Pitch.should_receive(:sort_by).and_return(named_scope)
      controller.send(:get_news_items)
    end
    it "should call paginate on the collection" do
      named_scope = mock('a named scope')
      named_scope.should_receive(:paginate).with(:all, :page => '1')
      Pitch.stub!(:sort_by).and_return(named_scope)
      controller.send(:get_news_items)
    end
  end
end
