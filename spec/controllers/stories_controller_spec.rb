require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do

  route_matches('/stories/1/edit', :get, :controller => 'stories',
                                               :action     => 'edit',
                                               :id => "1")

  route_matches('/stories/1', :put, :controller => 'stories',
                                          :action     => 'update',
                                          :id => "1")
                                          
  route_matches('/stories/1', :get, :controller => 'stories',
                                          :action     => 'show',
                                          :id => "1")
  route_matches('/stories/1/publish', :put, :controller => 'stories',
                                          :action     => 'publish',
                                          :id => "1")
  route_matches('/stories/1/accept', :put, :controller => 'stories',
                                          :action     => 'accept',
                                          :id => "1")
  route_matches('/stories/1/reject', :put, :controller => 'stories',
                                          :action     => 'reject',
                                          :id => "1")
  route_matches('/stories/1/fact_check', :put, :controller => 'stories',
                                          :action     => 'fact_check',
                                          :id => "1")
                                          
  describe "can_edit?" do
    it "should allow owner to edit if in draft state" do
      user = Factory(:user)
      story = Factory(:story, :user => user)
      controller.stub!(:current_user).and_return(user)
      get :edit, :id => story.id 
    end
    
    it "should not allow the owner to edit if it is in any state other than draft" do
      user = Factory(:user)
      story = Factory(:story, :user => user, :status => "accepted")
      controller.stub!(:current_user).and_return(user)
      get :edit, :id => story.id
      flash[:error].should_not be_nil
    end
    
  end
  
  describe "changing state" do
    
    it "should accept a story" do 
      user = Factory(:reporter)
      controller.stub!(:current_user).and_return(user)
      story = Factory(:story, :status => "fact_check")     
      story.fact_checker = user
      story.save
      put "accept", :id => story.to_param
      story.reload
      story.should be_ready
    end
                             
    it "should reject a story" do
      user = Factory(:reporter)
      controller.stub!(:current_user).and_return(user)
      story = Factory(:story, :status => "fact_check")     
      story.fact_checker = user
      story.save
      put "reject", :id => story.to_param
      story.reload
      story.should be_draft
    end
    
    it "should fact_check a story" do
      user = Factory(:reporter)
      controller.stub!(:current_user).and_return(user)
      story = Factory(:story, :status => "draft")     
      story.fact_checker = user
      story.save
      put "fact_check", :id => story.to_param
      story.reload
      story.should be_fact_check
    end
    
    it "should publish a story" do
      user = Factory(:reporter)
      controller.stub!(:current_user).and_return(user)
      story = Factory(:story, :status => "ready")     
      story.fact_checker = user
      story.save
      put "publish", :id => story.to_param
      story.reload
      story.should be_published
    end
  end

  describe "#find_resources" do
    before do
      controller.stub!(:current_network).and_return(Factory(:network))
      @published = []
      @by_network = stub('by_network', :published => @published)
    end
    it "should load stories for the current network" do
      Story.should_receive(:by_network).and_return(@by_network)
      controller.send(:find_resources)
    end
    it "should load published stories" do
      Story.stub!(:by_network).and_return(@by_network)
      @by_network.should_receive(:published).and_return(@published)
      controller.send(:find_resources)
    end
  end
end
