require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  before do
    @user = Factory(:user)
    controller.stubs(:current_user).returns(@user)
    request.env["HTTP_REFERER"] = root_url
  end

  describe "GET to index" do
    describe "coming from a pitch" do
      before do
        @pitch = Factory(:pitch)
      end
      it "redirects to pitch page" do
        get :index, :pitch_id => @pitch.id
        response.should redirect_to(pitch_path(@pitch))
      end
    end
    describe "coming from a story" do
      before do
        @story = Factory(:story)
      end

      it "redirects to the story page" do
        get :index, :story_id => @story.id
        response.should redirect_to(story_path(@story))
      end
    end
  end
  describe "POST to create" do
    before do
      @pitch = Factory(:pitch)
      @user = Factory(:user)
      Pitch.stub!(:find).and_return(@pitch)
    end

    describe "with a logged in user" do
      describe "bot negative captcha" do
        it "remove the blog_url from the params" do
          post :create, :comment => {:title => 'foo', :body => 'bar', :blog_url => 'anything'}, :pitch_id => @pitch.id
          params[:comment].should_not have_key(:blog_url)
        end

        it "redirects to back when there is a bot who filled in the blog url" do
          post :create, :comment => {:title => 'foo', :body => 'bar', :blog_url => 'anything'}, :pitch_id => @pitch.id
          response.should redirect_to(root_path)
        end
      end

      it "success" do
        post :create, :comment => {:title => 'foo', :body => 'bar'}, :pitch_id => @pitch.id
        flash[:notice].should be
      end

      it "errors" do
        controller.stubs(:resource_saved?).returns(false)
        post :create, :comment => {:title => '', :body => ''}, :pitch_id => @pitch.id
        response.should redirect_to(pitch_path(@pitch))
      end
    end

    describe "without a logged in user" do
      before do
        controller.stubs(:current_user).returns(nil)
      end
      it "stores location and shows login/register facebox" do
        post :create, :comment => {:title => 'foo', :body => 'bar'}, :pitch_id => @pitch.id
      end
    end
  end
end
