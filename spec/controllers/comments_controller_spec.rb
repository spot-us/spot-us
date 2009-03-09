require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do
  describe "POST to create" do
    before do
      @pitch = Factory(:pitch)
      @user = Factory(:user)
      Pitch.stub!(:find).and_return(@pitch)
    end

    describe "with a logged in user" do
      before do
        controller.stub!(:current_user).and_return(@user)
      end

      it "success" do
        post :create, :comment => {:title => 'foo', :body => 'bar'}, :pitch_id => @pitch.id
        flash[:notice].should be
      end

      it "errors" do
        post :create, :comment => {:title => '', :body => ''}, :pitch_id => @pitch.id
        response.should render_template('new')
      end
    end
  end
end
