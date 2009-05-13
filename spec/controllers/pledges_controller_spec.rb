require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PledgesController do
  describe "on POST to create with valid input" do
    before do
      login_as @user = Factory(:user)
      @tip = Factory(:tip)
    end

    it "should create a valid pledge" do
      do_create
      assigns[:pledge].should_not be_nil
      assigns[:pledge].should be_valid
    end

    it "should associate pledge with current user" do
      do_create
      assigns[:pledge].user_id.should == @user.id
    end

    it "should associate pledge with the tip" do
      do_create
      assigns[:pledge].tip.should == @tip
    end

    def do_create
      xhr :post, :create, :pledge => {:tip_id => @tip.id, :amount => 25}
    end
  end

  describe "on POST to create with invalid input" do
    before do
      request.env["HTTP_REFERER"] = '/'
      controller.stubs(:login_required).returns(true)
      controller.stubs(:resource_saved?).returns(false)
      controller.stubs(:current_user).returns(Factory(:citizen))
    end
    it "should set a flash error" do
      post :create, :pledge => {}
      flash[:error].should_not be_nil
    end
    it "redirects back" do
      post :create, :pledge => {}
      response.should redirect_to('/')
    end
  end

  describe "when can't edit" do
    before(:each) do
      pledge = Factory(:pledge)
      pledge.stub!(:editable_by?).and_return(false)
      Pledge.stub!(:find).and_return(pledge)
      get :edit, :id => pledge.id
    end
    it_denies_access
  end

  describe "on DELETE to destroy" do
    before do
      login_as @user = Factory(:user)
      @tip = Factory(:tip, :user => @user)
      @pledge = @tip.pledges.first
    end

    it "should remove the pledge" do
      do_destroy
      Pledge.find_by_id(@pledge.id).should be_nil
    end

    it "should redirect to /myspot/pledges" do
      do_destroy
      response.should redirect_to(myspot_pledges_path)
    end

    def do_destroy
      #Pledge.stub!(:editable_by?).and_return(true)
      delete :destroy, :id => @pledge.id
    end
  end

  describe "on PUT to update with valid input" do
    before do
      login_as @user = Factory(:user)
      @tip = Factory(:tip, :user => @user)
      @pledge = @tip.pledges.first
    end

    it "should update the pledge" do
      do_update
      assigns[:pledge].should_not be_nil
      assigns[:pledge].should be_valid
      assigns[:pledge].amount.should == 75.0
    end

    def do_update
      Pledge.stub!(:editable_by?).and_return(true)
      xhr :put, :update, :id => @pledge.id, :pledge => {:amount => 75}
    end
  end
end
