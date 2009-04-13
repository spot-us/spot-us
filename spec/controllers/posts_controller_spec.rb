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
      controller.stubs(:current_user).returns(Factory(:reporter))
      controller.stubs(:enclosing_resource).returns(@pitch)
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
      controller.stubs(:params).returns({'post' => {'title' => 'title', 'body' => 'body'}})
      controller.stubs(:current_user).returns(@reporter)
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
