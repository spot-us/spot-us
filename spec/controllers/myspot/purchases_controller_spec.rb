require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Myspot::PurchasesController do

  route_matches("/myspot/purchases", :post, :controller => "myspot/purchases",
                                            :action => "create")
  route_matches("/myspot/purchases/new", :get, :controller => "myspot/purchases",
                                               :action => "new")

  describe "on GET to new when the user has unpaid donations" do
    before do
      @user = Factory(:user)
      @pitches = [active_pitch, active_pitch]
      @donations = @pitches.collect {|pitch| Factory(:donation,
                                                     :user  => @user,
                                                     :pitch => pitch) }

      controller.stubs(:current_user).returns(@user)
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
      controller.expects(:current_user).at_least(1).returns(@user)
      do_new
    end

    it "should find donations for the current user" do
      @user.should_receive(:donations).at_least(1).and_return(@donations)
      do_new
    end

    it "should only find unpaid donations" do
      @donations.should_receive(:unpaid).at_least(1).and_return(@donations)
      do_new
    end

    it "should allow only spotus donations" do
      donations = stub('named_scope', :unpaid => [])
      @user.stub!(:donations).and_return(donations)
      @user.stub!(:unpaid_spotus_donation).and_return(Factory(:spotus_donation))
      purchase = Factory(:purchase)
      Purchase.should_receive(:new).and_return(purchase)
      do_new
      assigns[:purchase].should == purchase
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

    it "should redirect my donations page" do
      do_new
      response.should redirect_to(myspot_donations_path)
    end

    def do_new
      get :new
    end
  end

  describe "on POST to create with valid input" do
    integrate_views

    before do
      @user = Factory(:user)
      @pitches = [active_pitch, active_pitch]
      @donations = @pitches.collect {|pitch| Factory(:donation,
                                                     :user  => @user,
                                                     :pitch => pitch) }
      controller.stubs(:current_user).returns(@user)
      login_as @user
    end

    it "should redirect to the myspot donations path" do
      do_create
      response.should redirect_to(myspot_donations_path)
    end

    it "should create a new purchase" do
      lambda { do_create }.should change { Purchase.count }.by(1)
    end

    it "should update the balance_text cookie after a successful donation" do
      controller.stubs(:current_balance).returns(10)
      @user.stub!(:credits?).and_return(true)
      @user.stub!(:total_credits).and_return(30.89)
      do_create
      URI.decode(response.cookies['balance_text']).should include('$30.89')
    end

    def do_create
      post :create, :purchase => Factory.attributes_for(:purchase)
    end
  end

  describe "on POST to create with invalid input" do
    before do
      @user = Factory(:user)
      @donations = [Factory(:donation, :user => @user)]
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
      @donations = [Factory(:donation, :user => @user, :status => 'unpaid')]
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

  describe "PayPal response" do
    before do
      @params =  {"protection_eligibility"=>"Eligible", 
        "tax"=>"0.00",
        "payment_status"=>"Completed",
        "address_name"=>"Test User",
        "business"=>"dev+pa_1239041752_biz@hashrocket.com",
        "address_country"=>"United States",
        "address_city"=>"San Jose",
        "payer_email"=>"dev+pa_1239041717_per@hashrocket.com",
        "receiver_id"=>"HQ79EJ4KFPWAU",
        "residence_country"=>"US",
        "payment_gross"=>"440.00",
        "mc_shipping"=>"0.00",
        "receiver_email"=>"dev+pa_1239041752_biz@hashrocket.com",
        "mc_gross_1"=>"200.00",
        "address_street"=>"1 Main St",
        "mc_handling1"=>"0.00",
        "verify_sign"=>"AVv2fa0VdjSSQ6PhgLCpIgZ3PpygAdpa6bB9AXSMUbqY5xLKMkkniUrh",
        "mc_gross_2"=>"200.00",
        "address_zip"=>"95131",
        "mc_handling2"=>"0.00",
        "item_name1"=>"PITCH: testing testing",
        "txn_type"=>"cart",
        "mc_currency"=>"USD",
        "mc_gross_3"=>"40.00",
        "transaction_subject"=>"Shopping Cart",
        "charset"=>"windows-1252",
        "address_country_code"=>"US",
        "mc_handling3"=>"0.00",
        "txn_id"=>"0PB07920SY555151E",
        "item_name2"=>"PITCH: testing testing",
        "item_number1"=>"",
        "notify_version"=>"2.8",
        "payer_status"=>"verified",
        "tax1"=>"0.00",
        "address_state"=>"CA",
        "payment_fee"=>"13.06",
        "item_name3"=>"Support Spot.Us",
        "quantity1"=>"1",
        "address_status"=>"confirmed",
        "item_number2"=>"",
        "payment_date"=>"13:16:29 Apr 14, 2009 PDT",
        "mc_handling"=>"0.00",
        "mc_fee"=>"13.06",
        "tax2"=>"0.00",
        "quantity2"=>"1",
        "item_number3"=>"",
        "first_name"=>"Test",
        "num_cart_items"=>"3",
        "mc_shipping1"=>"0.00",
        "tax3"=>"0.00",
        "payment_type"=>"instant",
        "quantity3"=>"1",
        "test_ipn"=>"1",
        "mc_gross"=>"440.00",
        "payer_id"=>"XABGXAPTSL7QS",
        "mc_shipping2"=>"0.00",
        "last_name"=>"User",
        "custom"=>"",
        "mc_shipping3"=>"0.00"}
    end

    describe "when the payment has been completed" do
      it "posts to the paypal url with an additional cmd parameter" do
        HTTParty.expects(:post).with(PAYPAL_POST_URL, @params.merge({"cmd" => "_notify_validate"}))
        post :paypal_response, @params
      end
    end

    describe "when a payment was been successful" do
      it "creates a purchase"
      it "marks donations paid"
      it "marks the spot-us donation paid"
    end

    describe "when a payment was unsuccessful" do
      it "does not mark donations paid"
      it "does not mark the spot-us donation paid"
    end
  end

  requires_login_for :get, :new
  requires_login_for :post, :create

end
