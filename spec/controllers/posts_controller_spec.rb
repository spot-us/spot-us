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
    it "should ask the pitch for authorization" do
      controller.stub!(:current_user).and_return(Factory(:reporter))
      controller.stub!(:enclosing_resource).and_return(@pitch)
      @pitch.should_receive(:postable_by?).and_return(true)
      controller.send(:authorized?).should be_true
    end
  end

  describe "deleting a post" do
    it "should redirect to the myspot blog posts page" do
      delete :destroy, :id => @post.id, :pitch_id => @pitch.id
      response.should redirect_to(myspot_posts_path)
    end
  end

  describe "new_resource" do
    before do
      controller.stub!(:params).and_return({'post' => {'title' => 'title', 'body' => 'body'}})
      controller.stub!(:current_user).and_return(@reporter)
    end
    it "should assign the current user as the post's author" do
      post = controller.send(:new_resource)
      post.user.should == @reporter
    end
    it "should set the params for the new post" do
      post = controller.send(:new_resource)
      post.title.should == 'title'
      post.body.should == 'body'
    end
  end
end
