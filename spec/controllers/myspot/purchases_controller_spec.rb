require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
include ActiveMerchant::Billing::Integrations

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

    describe "paypal actions" do
      before do
        @purchase = Factory(:purchase)
        Purchase.stub!(:new).and_return(@purchase)
      end
      it "creates a paypal cart from the purchase" do
        PaypalCart.should_receive(:create_from_purchase).with(@purchase)
        do_new
      end

      it "assigns a paypal_cart instance variable" do
        do_new
        assigns[:paypal_cart].should == @paypal_cart
      end
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
      @paypal_params =  {"protection_eligibility"=>"Eligible", "tax"=>"0.00",
        "payment_status"=>"Completed", "address_name"=>"Test User", 
        "business"=>"dev+pa_1239041752_biz@hashrocket.com", "address_country"=>"United States", 
        "address_city"=>"San Jose", "payer_email"=>"dev+pa_1239041717_per@hashrocket.com", 
        "receiver_id"=>"HQ79EJ4KFPWAU", "residence_country"=>"US", "payment_gross"=>"240.00", 
        "mc_shipping"=>"0.00", "receiver_email"=>"dev+pa_1239041752_biz@hashrocket.com", 
        "mc_gross_1"=>"200.00", "address_street"=>"1 Main St",
        "mc_handling1"=>"0.00",
        "verify_sign"=>"A0WBa-tiI74WL8XPUwsW.95bvjWUAaAFF-mwVweS-RtjNFGpKWiQmUQn",
        "mc_gross_2"=>"40.00", "address_zip"=>"95131", "mc_handling2"=>"0.00",
        "item_name1"=>"PITCH: testing testing", "txn_type"=>"cart",
        "mc_currency"=>"USD", "transaction_subject"=>"Shopping Cart",
        "charset"=>"windows-1252", "address_country_code"=>"US",
        "txn_id"=>"28C98632UU123291R", "item_name2"=>"Support Spot.Us",
        "item_number1"=>"128", "notify_version"=>"2.8",
        "payer_status"=>"verified", "tax1"=>"0.00", "address_state"=>"CA",
        "payment_fee"=>"7.26", "quantity1"=>"1", "address_status"=>"confirmed",
        "item_number2"=>"14", "payment_date"=>"06:26:34 Apr 15, 2009 PDT",
        "mc_handling"=>"0.00", "mc_fee"=>"7.26", "tax2"=>"0.00",
        "quantity2"=>"1", "first_name"=>"Test", "num_cart_items"=>"2",
        "mc_shipping1"=>"0.00", "payment_type"=>"instant", "test_ipn"=>"1",
        "mc_gross"=>"240.00", "payer_id"=>"XABGXAPTSL7QS",
        "mc_shipping2"=>"0.00", "last_name"=>"User", "custom"=>""}
    end

    describe "when the payment has been completed" do
      def do_post
        post :paypal_ipn, @paypal_params
      end
      before do
        @user = mock_model(User)
        @donation = mock_model(Donation, :amount => 200.00, :unpaid? => true, :user => @user)
        @donations = [@donation]
        @spotus_donation = mock_model(SpotusDonation, :amount => 40.00, :unpaid? => true, :user => @user)
        SpotusDonation.stub!(:find_from_paypal).and_return(@spotus_donation)
        Donation.stub!(:find_all_from_paypal).and_return(@donations)
        @purchase = mock_model(Purchase, :total_amount => 240.00)
        @purchase.stub!(:donations=)
        @purchase.stub!(:spotus_donation=)
        @purchase.stub!(:user=)
        @purchase.stub!(:paypal_transaction_id=)
        Purchase.stub!(:new).and_return(@purchase)
        @notify = stub('notify', :params => @paypal_params, :acknowledge => false, :amount => "240", :transaction_id => '17')
        Paypal::Notification.stub!(:new).and_return(@notify)
      end
      it "finds spotus donation" do
        SpotusDonation.should_receive(:find_from_paypal).with(@paypal_params).and_return(@spotus_donation)
        do_post
      end
      it "finds the donation" do
        Donation.should_receive(:find_all_from_paypal).and_return(@donations)
        do_post
      end
      it "logs an error if the donations don't all have the same user" do
        @donations << mock_model(Donation, :user => mock_model(User))
        controller.logger.should_receive(:error).with('Invalid users for PayPal transaction 28C98632UU123291R')
        do_post
      end
      it "creates a new purchase" do
        Purchase.should_receive(:new).and_return(@purchase)
        @purchase.should_receive(:donations=).with(@donations)
        @purchase.should_receive(:spotus_donation=).with(@spotus_donation)
        @purchase.should_receive(:user=).with(@user)
        do_post
      end
      it "stores the purchase id" do
        @purchase.should_receive(:paypal_transaction_id=).with('17')
        do_post
      end
      it "acknowledges the notification" do
        @notify.should_receive(:acknowledge)
        do_post
      end
      it "doesn't create a purchase if any donations are unpaid" do
        Purchase.stub!(:valid_donations_for_user?).and_return(false)
        Purchase.should_receive(:new).exactly(0)
        do_post
      end
      it "logs an error if the acknowledgement fails" do
        @notify.should_receive(:acknowledge).and_return(false)
        controller.logger.should_receive(:error).with("Failed to verify Paypal's notification, please investigate: 28C98632UU123291R")
        do_post
      end
      it "saves the purchase if paypal verifies the payment and the total is correct" do
        @notify.should_receive(:acknowledge).and_return(true)
        @notify.should_receive(:complete?).and_return(true)
        @purchase.should_receive(:save)
        do_post
      end
      it "doesn't save a purchase otherwise" do
        @notify.should_receive(:acknowledge).and_return(true)
        @notify.should_receive(:complete?).and_return(false)
        @purchase.should_receive(:save).never
        controller.logger.stub!(:error)
        do_post
      end
      it "logs an error if paypal doesn't verify the payment or the total is incorrect" do
        controller.logger.should_receive(:error).with("PayPal acknowledgement was unpaid or the amounts didn't match for the following transaction: 28C98632UU123291R").once
        @notify.stub!(:acknowledge).and_return(true)
        @notify.stub!(:complete?).and_return(false)
        do_post
      end
    end

    describe "#paypal_return" do
      before do
        @user = mock_model(User)
        @donations = stub('named scope', :unpaid => [])
        @user.stub!(:donations).and_return(@donations)
        controller.stubs(:current_user).returns(@user)
      end
      it "updates the balance cookie" do
        controller.should_receive(:update_balance_cookie)
        get :paypal_return
      end
      it "shows a success message if the user's donations are all paid" do
        get :paypal_return
        flash[:success].should == "Thanks! Your payment has been received."
      end
      it "shows a pending message if the user has unpaid donations still" do
        @user.donations.unpaid.stub!(:any?).and_return(true)
        get :paypal_return
        flash[:success].should == "Thanks! Your donations will be marked paid when PayPal clears them."
      end
    end
  end

  requires_login_for :get, :new
  requires_login_for :post, :create

end
