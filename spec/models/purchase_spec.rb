require File.dirname(__FILE__) + '/../spec_helper'

describe Purchase do
  table_has_columns(Purchase, :string, "first_name")
  table_has_columns(Purchase, :string, "last_name")
  table_has_columns(Purchase, :string, "credit_card_number_ending")
  table_has_columns(Purchase, :string, "address1")
  table_has_columns(Purchase, :string, "address2")
  table_has_columns(Purchase, :string, "city")
  table_has_columns(Purchase, :string, "state")
  table_has_columns(Purchase, :string, "zip")
  table_has_columns(Purchase, :integer, "user_id")

  requires_presence_of_field_on_purchase(Purchase, :first_name)
  requires_presence_of_field_on_purchase(Purchase, :last_name)
  requires_presence_of_field_on_purchase(Purchase, :address1)
  requires_presence_of_field_on_purchase(Purchase, :city)
  requires_presence_of_field_on_purchase(Purchase, :state)
  requires_presence_of_field_on_purchase(Purchase, :zip)
  requires_presence_of_field_on_purchase(Purchase, :user_id)
  requires_presence_of_field_on_purchase(Purchase, :credit_card_number)
  requires_presence_of_field_on_purchase(Purchase, :credit_card_month)
  requires_presence_of_field_on_purchase(Purchase, :credit_card_year)
  requires_presence_of_field_on_purchase(Purchase, :credit_card_type)
  requires_presence_of_field_on_purchase(Purchase, :verification_value)

  describe "when a purchase happens" do
    before(:each) do
      @pitch = Factory(:pitch)
      @user = Factory(:user)
      @donation = Factory(:donation, :pitch => @pitch, :user => @user, :amount => 25)
    end

    it "should update current_funding for a pitch when donation is paid" do
      lambda {
        Factory(:purchase, :user => @user, :donations => [@donation])
        @pitch.reload
      }.should change {@pitch.current_funding}.from(0).to(25)
    end

    it "should not update current_funding for a pitch if the donation has not been purchased" do
      @pitch.reload
      @pitch.current_funding.should == 0
    end

    describe "and credits cover amount owed" do

      it "should not bill the credit card" do
        Factory(:credit, :amount => 25, :user => @user)

        purchase = Factory.build(:purchase, :user => @user, :donations => [@donation])
        purchase.gateway.should_receive(:purchase).never

        purchase.save
      end

      it "missing personal data won't fail validations" do
        Factory(:credit, :amount => 25, :user => @user)

        purchase = Purchase.new(:user => @user, :donations => [@donation])
        purchase.should be_valid
      end

    end
  end

  it "should have a gateway" do
    Purchase.gateway.should_not be_nil
    Purchase.gateway.should be_instance_of(ActiveMerchant::Billing::BogusGateway)
  end

  it do
    Purchase.should belong_to(:user)
  end

  it do
    Purchase.should have_many(:donations)
  end

  describe "when new being validated with an invalid credit card" do
    before do
      @credit_card = Factory.build(:credit_card, :type => 'fake')
      violated "credit card must be invalid" if @credit_card.valid?
      @donation = Factory(:donation, :pitch => Factory(:pitch), :user => Factory(:user), :amount => 25)
      ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(@credit_card)
      @purchase = Factory.build(:purchase, :user => Factory(:user), :donations => [@donation])
    end

    it "should validate the credit card" do
      @credit_card.should_receive(:valid?).at_least(1).with().and_return(false)
      do_validate
    end

    it "should not be valid" do
      do_validate
      @purchase.should_not be_valid
    end

    it "should append errors from the credit card" do
      do_validate
      @purchase.should have(1).error_on(:credit_card_type)
    end

    def do_validate
      @purchase.valid?
    end
  end

  it "should raise a gateway error when the gateway does not return a success response" do
    @donation = Factory(:donation, :pitch => Factory(:pitch), :user => Factory(:user), :amount => 25)
    lambda { Factory(:purchase, :credit_card_number => '2', :donations => [@donation]) }.
      should raise_error(Purchase::GatewayError,
                         ActiveMerchant::Billing::BogusGateway::FAILURE_MESSAGE)
  end

  describe "when new with valid credit card info being saved" do
    before do
      @credit_card = Factory.build(:credit_card)
      ActiveMerchant::Billing::CreditCard.stub!(:new).and_return(@credit_card)
      @user = Factory(:user)
      @total = 100
      @donation = Factory(:donation, :amount => @total, :user => @user)
      @purchase = Factory.build(:purchase, :user => @user, :donations => [@donation])
    end

    it "should build a new credit card" do
      hash = { :first_name         => @purchase.first_name,
               :last_name          => @purchase.last_name,
               :number             => @purchase.credit_card_number,
               :month              => @purchase.credit_card_month,
               :year               => @purchase.credit_card_year,
               :verification_value => @purchase.verification_value,
               :type               => @purchase.credit_card_type }
      ActiveMerchant::Billing::CreditCard.
        should_receive(:new).
        with(hash).
        and_return(@credit_card)
      do_save
    end

    it "should be valid" do
      do_save
      violated @purchase.errors.full_messages.join(', ') unless @purchase.valid?
    end

    it "should bill the credit card" do
      full_name = [@purchase.first_name, @purchase.last_name].join(' ')
      hash = { :billing_address => {
        :address1 => @purchase.address1,
        :address2 => @purchase.address2,
        :city     => @purchase.city,
        :state    => @purchase.state,
        :country  => 'US',
        :zip      => @purchase.zip,
        :email    => @purchase.user.email
      } }
      Purchase.gateway.should_receive(:purchase).
        with(@total.to_cents, @credit_card, hash).
        and_return(mock('response', :success? => true))
      do_save
    end

    it "should receive a success response from the gateway" do
      lambda { do_save }.should_not raise_error
    end

    def do_save
      @purchase.save
    end
  end



  it "should set the credit card ending when being saved with a credit card number" do
    @purchase = Factory.build(:purchase, :credit_card_number => '12345678')

    unless @purchase.credit_card_number_ending.blank?
      violated "purchase has a credit card number ending"
    end
    if @purchase.credit_card_number.blank?
      violated "purchase does not have a credit card number"
    end

    @purchase.save

    @purchase.credit_card_number_ending.should == '5678'
  end

  it "should calculate the total when donations are set" do
    @user = Factory(:user)
    @purchase = Factory.build(:purchase)
    @donations = [Factory(:donation, :amount => 5),
                  Factory(:donation, :amount => 10)]
    @purchase.donations = @donations
    @spotus_donation = Factory(:spotus_donation, :user => @user, :amount => 1)
    @purchase.spotus_donation = @spotus_donation
    @purchase.total_amount.should == 16.0
  end

  it "should take credits into account when calculating total" do
    @user = Factory(:user)
    Factory(:credit, :user => @user, :amount => 10)
    @purchase = Factory.build(:purchase, :user => @user)
    @donations = [Factory(:donation, :amount => 5),
                  Factory(:donation, :amount => 10)]
    @purchase.donations = @donations
    @spotus_donation = Factory(:spotus_donation, :user => @user, :amount => 1)
    @purchase.spotus_donation = @spotus_donation
    @purchase.total_amount.should == 6.0
  end

  it "should only use the amount needed when applying credits" do
    @user = Factory(:user)
    Factory(:credit, :user => @user, :amount => 20)
    @purchase = Factory.build(:purchase, :user => @user)
    @donations = [Factory(:donation, :amount => 5),
                  Factory(:donation, :amount => 10)]
    @purchase.donations = @donations
    @spotus_donation = Factory(:spotus_donation, :user => @user, :amount => 1)
    @purchase.spotus_donation = @spotus_donation
    @purchase.total_amount.should == 0.0
  end

  describe "after being saved with donations and spotus_donation" do
    before do
      @user = Factory(:user)
      @purchase = Factory.build(:purchase, :user => @user)
      @donations = [Factory(:donation, :amount => 5),
                    Factory(:donation, :amount => 10)]
      @purchase.donations = @donations
      @spotus_donation = Factory(:spotus_donation, :user => @user, :purchase => nil,
                                 :amount => 1)
      @purchase.spotus_donation = @spotus_donation

      Purchase.gateway.stub!(:purchase).and_return(mock('response', :success? => true))

      @purchase.save!
      @purchase.reload
      @donations.each {|donation| donation.reload }
    end

    it "should use the sum of the donations as the total" do
      @purchase.total_amount.should == '16.0'
    end

    it "should assign itself as the purchase for each donation" do
      @donations.detect {|donation| donation.purchase != @purchase }.
        should be_nil
    end

    it "should assign itself as the purchase for the spotus donation" do
      @spotus_donation.reload
      @spotus_donation.purchase.should == @purchase
    end

    it "should mark each donation as paid" do
      @donations.detect {|donation| !donation.paid? }.
        should be_nil
    end

  end

  describe "after being saved with donations and credits" do
    before do
      @user = Factory(:user)
      credit = Factory(:credit, :user => @user, :amount => 20)
      @purchase = Factory.build(:purchase, :user => @user)
      @donations = [Factory(:donation, :amount => 5),
                    Factory(:donation, :amount => 10)]
      @purchase.donations = @donations
      @spotus_donation = Factory(:spotus_donation, :user => @user, :amount => 1)
      @purchase.spotus_donation = @spotus_donation

      Purchase.gateway.stub!(:purchase).and_return(mock('response', :success? => true))

      @purchase.save!
      @purchase.reload
      @donations.each {|donation| donation.reload }
    end

    it "should use the sum of the donations minus the credits" do
      @purchase.total_amount.should == '0.0'
    end

    it "should create a credit for the amount of the credit applied" do
      @user.reload
      @user.credits.count.should == 2
      @user.credits.map{|c| c.amount}.should include(-16.0)
    end
  end
end

