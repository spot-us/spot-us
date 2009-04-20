require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "#current_network" do
    before do
      controller.stubs(:current_subdomain).returns('sfbay')
      @network = Factory(:network, :name => 'sfbay')
      Network.stub!(:find_by_name).and_return(@network)
    end

    it "should ask for the current subdomain" do
      controller.expects(:current_subdomain).returns('sfbay')
      controller.current_network
    end

    it "should load the network for the current domain" do
      Network.should_receive(:find_by_name).with('sfbay').and_return(@network)
      controller.current_network.should == @network
    end

    it "should lower case the network name" do
      controller.stubs(:current_subdomain).returns('SFBAY')
      Network.should_receive(:find_by_name).with('sfbay').and_return(@network)
      controller.current_network
    end

    it "should return nil if it can't find one" do
      Network.stub!(:find_by_name).and_return(nil)
      controller.current_network.should == nil
    end

    it "should create a current_network instance variable" do
      controller.current_network
      controller.instance_variable_get(:@current_network).should == @network
    end

    it "should use the instance variable instead of querying the database" do
      controller.instance_variable_set(:@current_network, @network)
      Network.should_receive(:find_by_name).never
      controller.current_network
    end
  end

  describe "#url_for_news_item" do
    before do
      @pitch = active_pitch
      @tip = Factory(:tip)
      @story = Factory(:story)
    end

    it 'generates a link to a pitch' do
      controller.send(:url_for_news_item, @pitch).should == pitch_path(@pitch)
    end
    it 'generates a link to a tip' do
      controller.send(:url_for_news_item, @tip).should == tip_path(@tip)
    end
    it 'generates a link to a story' do
      controller.send(:url_for_news_item, @story).should == story_path(@story)
    end
  end

  describe "#store_comment_for_non_logged_in_user" do
    before do
      controller.stub!(:params).and_return({"action"=>"create", "controller"=>"comments", "commentable_id"=>"1", "comment"=>{"body"=>"bar", "title"=>"foo"}})
    end
    it "saves the comment title and body to session" do
      controller.send(:store_comment_for_non_logged_in_user)
      session[:title].should_not be_nil
      session[:body].should_not be_nil
    end
    it "calls params_for_comment" do
      controller.should_receive(:params_for_comment)
      controller.send(:store_comment_for_non_logged_in_user)
    end
    it "stores the url_for_news_item return_to url" do
      controller.stub!(:url_for_news_item).and_return('a url')
      controller.send(:store_comment_for_non_logged_in_user)
      session[:return_to].should == 'a url'
    end
  end

  describe "#params_for_comment" do
    before do
      @html_params = {"action"=>"create", "controller"=>"comments", "commentable_id"=>"1", "comment"=>{"body"=>"bar", "title"=>"foo"}}
      @js_params = {:title => "foo", :body => "bar", :commentable_id => "1"}
    end

    it "returns title, body and news_item_id for html params" do
      controller.send(:params_for_comment, @html_params).should == ["foo", "bar", "1"]
    end
    it "returns title, body and news_item_id for javascript params" do
      controller.send(:params_for_comment, @js_params).should == ["foo", "bar", "1"]
    end
  end
end
