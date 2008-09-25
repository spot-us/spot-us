require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TipsController do

  describe "on GET to /tips/new" do
    before(:each) do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      get :new
    end

    it "assigns the new tip the current user" do
      assigns(:tip).user_id.should == @user.id
    end
  end

  describe "on GET to new with a headline" do
    before do
      login_as Factory(:user)
      get :new, :headline => 'example'
    end

    it "should prefill the headline on the tip" do
      assigns[:tip].headline.should == 'example'
    end
  end

end
