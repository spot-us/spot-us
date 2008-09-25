require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::PurchasesController do

  route_matches("/myspot/purchase", :post, :controller => "myspot/purchases",
                                           :action => "create")
  route_matches("/myspot/purchase/new", :get, :controller => "myspot/purchases",
                                              :action => "new")

  describe "on GET to new when the user has unpaid donations" do
    before do
      @user = Factory(:user)
      @pitches = [Factory(:pitch), Factory(:pitch)]
      @donations = @pitches.collect {|pitch| Factory(:donation,
                                                     :user  => @user,
                                                     :pitch => pitch,
                                                     :paid  => false) }

      controller.stub!(:current_user).and_return(@user)
      @user.stub!(:donations).and_return(@donations)
      @donations.stub!(:unpaid).and_return(@donations)

      login_as @user
    end

    it "should be successful" do
      do_new
      response.should be_success
    end

    it "should prefill the first and last name from the user" do
      do_new
      assigns[:purchase].first_name.should == @user.first_name
      assigns[:purchase].last_name.should == @user.last_name
    end

    it "should render the new view" do
      do_new
      response.should render_template('new')
    end

    it "should assign donations for the view" do
      do_new
      assigns[:donations].should == @donations
    end

    it "should assign a new purchase for the view" do
      do_new
      assigns[:purchase].should_not be_nil
      assigns[:purchase].should be_instance_of(Purchase)
    end

    it "should find the current user" do
      controller.should_receive(:current_user).at_least(1).with().and_return(@user)
      do_new
    end

    it "should find donations for the current user" do
      @user.should_receive(:donations).at_least(1).with().and_return(@donations)
      do_new
    end

    it "should only find unpaid donations" do
      @donations.should_receive(:unpaid).at_least(1).with().and_return(@donations)
      do_new
    end

    def do_new
      get :new
    end
  end

  describe "on GET to new when the user has no unpaid donations" do
    before do
      @user = Factory(:user)
      unless @user.donations.unpaid.empty?
        violated "user should not have unpaid donations" 
      end
      login_as @user
    end

    it "should redirect home" do
      do_new
      response.should redirect_to(root_path)
    end

    def do_new
      get :new
    end
  end

  describe "on POST to create with valid input" do
    before do
      @user = Factory(:user)
      @pitches = [Factory(:pitch), Factory(:pitch)]
      @donations = @pitches.collect {|pitch| Factory(:donation,
                                                     :user  => @user,
                                                     :pitch => pitch) }
      login_as @user
    end

    it "should redirect to the receipt page" do
      do_create
      response.should be_redirect
    end

    it "should create a new purchase" do
      lambda { do_create }.should change { Purchase.count }.by(1)
    end

    it "should create a purchase for the current user" do
      do_create
      assigns[:purchase].user.should == User.find(@user.to_param)
    end
    
    it "should create a purchase for the current user's donations" do
      do_create
      assigns[:purchase].donations.should == @donations
    end

    def do_create
      post :create, :purchase => Factory.attributes_for(:purchase)
    end
  end

  describe "on POST to create with invalid input" do
    before do
      @user = Factory(:user)
      @donations = [Factory(:donation, :user => @user, :paid => false)]
      login_as @user
    end

    it "should render the purchase form" do
      do_create
      response.should render_template('new')
    end

    it "should not create a purchase" do
      lambda { do_create }.should_not change { Purchase.count }
    end

    it "should assign the donations for the view" do
      do_create
      assigns[:donations].should_not be_blank
    end

    it "should assign the purchase for the view" do
      do_create
      assigns[:purchase].should_not be_nil
    end

    def do_create
      post :create, :purchase => {}
    end
  end

  describe "on POST to create with a gateway error" do
    before do
      @user = Factory(:user)
      @donations = [Factory(:donation, :user => @user, :paid => false)]
      login_as @user
      Purchase.gateway.stub!(:purchase).and_raise(Purchase::GatewayError)
    end

    it "should render the purchase form" do
      do_create
      response.should render_template('new')
    end

    it "should not create a purchase" do
      lambda { do_create }.should_not change { Purchase.count }
    end

    it "should assign the donations for the view" do
      do_create
      assigns[:donations].should_not be_blank
    end

    it "should assign the purchase for the view" do
      do_create
      assigns[:purchase].should_not be_nil
    end

    it "should attempt to bill the credit card" do
      Purchase.gateway.
        should_receive(:purchase).
        once.
        and_raise(Purchase::GatewayError)
      do_create
    end

    it "should set a flash error message" do
      do_create
      flash[:error].should_not be_blank
    end

    def do_create
      post :create, :purchase => Factory.attributes_for(:purchase)
    end
  end
  requires_login_for :get, :new
  requires_login_for :post, :create

end
