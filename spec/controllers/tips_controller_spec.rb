require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TipsController do

  describe "on GET to /tips" do
    it "should redirect to /news_items" do
      get :index
      response.should redirect_to(news_items_path)
    end
  end

  describe "on GET to /tips/new" do
    before(:each) do
      @user = Factory(:user)
      controller.stubs(:current_user).returns(@user)
      get :new
    end

    it "assigns the new tip the current user" do
      assigns(:tip).user_id.should == @user.id
    end
  end

  describe "on GET to /tips/1/edit" do
    before do
      login_as Factory(:user)
    end

    describe "without pledges" do
      it "renders edit" do
        controller.stubs(:can_edit?).returns(true)
        t = Factory :tip
        get :edit, :id => t.to_param
        response.should render_template(:edit)
      end
    end

    describe "with a pledge" do
      it "renders edit" do
        controller.stubs(:can_edit?).returns(true)
        t = Factory :tip
        p = Factory :pledge, :tip => t
        get :edit, :id => t.to_param
        response.should redirect_to(tip_path(t))
        flash[:error].should match(/cannot edit a tip that has pledges/i)
      end
    end
  end

  describe "when can't edit" do
    before(:each) do
      tip = Factory(:tip)
      tip.stub!(:editable_by?).and_return(false)
      Tip.stub!(:find).and_return(tip)
      get :edit, :id => 1
    end
    it_denies_access
  end

  describe "when not logged in on get to edit" do
    before { get :new }
    it_denies_access
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
