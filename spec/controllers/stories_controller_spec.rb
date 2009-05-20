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
      controller.stubs(:current_user).returns(user)
      get :edit, :id => story.id
    end

    it "should not allow the owner to edit if it is in any state other than draft" do
      user = Factory(:user)
      story = Factory(:story, :user => user, :status => "accepted")
      controller.stubs(:current_user).returns(user)
      get :edit, :id => story.id
      flash[:error].should_not be_nil
    end

  end

  describe "changing state" do

    it "should accept a story" do
      user = Factory(:reporter)
      controller.stubs(:current_user).returns(user)
      story = Factory(:story, :status => "fact_check")
      story.fact_checker = user
      story.save
      put :accept, :id => story.to_param
      story.reload
      story.should be_ready
    end

    it "should reject a story" do
      user = Factory(:reporter)
      controller.stubs(:current_user).returns(user)
      story = Factory(:story, :status => "fact_check")
      story.fact_checker = user
      story.save
      put :reject, :id => story.to_param
      story.reload
      story.should be_draft
    end

    it "should fact_check a story" do
      user = Factory(:reporter)
      controller.stubs(:current_user).returns(user)
      story = Factory(:story, :status => "draft")
      story.fact_checker = user
      story.save
      put "fact_check", :id => story.to_param
      story.reload
      story.should be_fact_check
    end

    it "should publish a story" do
      user = Factory(:reporter)
      controller.stubs(:current_user).returns(user)
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
      controller.stubs(:current_network).returns(Factory(:network))
    end
    it "should load stories for the current network" do
      Story.stub_chain(:published, :paginate).and_return([])
      Story.should_receive(:by_network).and_return(Story)
      controller.send(:find_resources)
    end
    it "should load published stories" do
      Story.stub_chain(:by_network, :paginate).and_return([])
      Story.should_receive(:published).and_return(Story)
      controller.send(:find_resources)
    end
    it "paginates" do
      Story.stub_chain(:published, :by_network).and_return(Story)
      Story.should_receive(:paginate).and_return([])
      controller.send(:find_resources)
    end
  end
end
