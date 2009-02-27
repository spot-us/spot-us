require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do

  before do
    @reporter = Factory(:reporter)
    login_as @reporter
    @pitch = Factory(:pitch, :user => @reporter)
    Pitch.stub!(:find).and_return(@pitch)
    @post = Factory(:post, :pitch => @pitch)
  end

  describe "POST create" do
    describe "with valid params" do
      it "should redirect to myspot blog posts" do
        post :create, :post => {:title => 'Title', :body => 'Body'}, :pitch_id => 1
        response.should redirect_to(myspot_posts_path)
      end
    end
  end

  describe "#authorized?" do
    it "should return nil with no current_user" do
      controller.stub!(:current_user).and_return(nil)
      controller.send(:authorized?).should be_nil
    end
    it "should return true if the current user is an admin" do
      controller.stub!(:current_user).and_return(Factory(:admin))
      controller.send(:authorized?).should be_true
    end
    it "should return true if the current user is the reporter for the pitch" do
      user = Factory(:user)
      pitch = Factory(:pitch, :user => user)
      controller.stub!(:enclosing_resource).and_return(pitch)
      controller.stub!(:current_user).and_return(user)
      controller.send(:authorized?).should be_true
    end
    it "should return false if the current user is not the reporter or an admin" do
      controller.stub!(:enclosing_resource).and_return(Factory(:pitch))
      controller.stub!(:current_user).and_return(Factory(:user))
      controller.send(:authorized?).should be_false
    end
  end

  describe "deleting a post" do
    it "should redirect to the myspot blog posts page" do
      delete :destroy, :id => @post.id, :pitch_id => @pitch.id
      response.should redirect_to(myspot_posts_path)
    end
  end
end
