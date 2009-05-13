require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::DonationsController do
  route_matches("/myspot/donations", :get, :controller => "myspot/donations", :action => "index")

  route_matches("/myspot/donations", :post, :controller => "myspot/donations", :action => "create")

  route_matches("/myspot/donations/1", :delete, :id => "1", :controller => "myspot/donations", :action => "destroy")

  before do
    @user = Factory(:user)
    controller.stubs(:current_user).returns(@user)
  end

  describe "on DELETE to destroy" do
    before do
      @donation = Factory(:donation, :user => @user, :status => 'paid')
    end

    it "should remove the donation if paid" do
      Donation.find_by_id(@donation).should_not be_nil
      do_destroy
      Donation.find_by_id(@donation).should be_nil
    end

    it "should redirect to myspot donations AMOUNTS page ie. receipts page" do
      do_destroy
      response.should redirect_to(edit_myspot_donations_amounts_path)
    end

    def do_destroy
      delete :destroy, :id => @donation.id
    end
  end

  describe "on POST to create with valid input" do
    before do
      @pitch = active_pitch
    end

    it "should create a valid donation" do
      do_create
      assigns[:donation].should_not be_nil
      assigns[:donation].should be_valid
    end

    it "should associate donation with current user" do
      do_create
      assigns[:donation].user_id.should == @user.id
    end

    it "should associate donation with the pitch" do
      do_create
      assigns[:donation].pitch.should == @pitch
    end

    def do_create
      post :create, :donation => {:pitch_id => @pitch.id, :amount => 25}
    end
  end

  describe "on POST to create with invalid input" do
    before do
      request.env["HTTP_REFERER"] = '/'
      controller.stubs(:resource_saved?).returns(false)
    end

    it "sets a flash error message" do
      post :create, :donation => {}
      flash[:error].should_not be_nil
    end

    it "redirects to back" do
      post :create, :donation => {}
      response.should redirect_to('/')
    end
  end


  describe "on GET to index" do
    before do
      @donations = [Factory(:donation)]
      @user.stub!(:donations).and_return(@donations)
      @donations.stub!(:paid).and_return(@donations)
    end

    it "should response successfully" do
      do_index
      response.should be_success
    end

    it "should render the index view" do
      do_index
      response.should render_template('index')
    end

    it "should find the current user" do
      controller.expects(:current_user).at_least(1).with().returns(@user)
      do_index
    end

    it "should find the user's donations" do
      @user.should_receive(:donations).with().and_return(@donations)
      do_index
    end

    it "should only find paid donations" do
      @donations.should_receive(:paid).with().and_return(@donations)
      do_index
    end

    it "should assign the donations" do
      do_index
      assigns[:donations].should == @donations
    end

    def do_index
      get :index
    end
  end
end
