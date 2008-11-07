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
                                               
end