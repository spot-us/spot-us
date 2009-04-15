require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'purchases/new' do
  before do
    @user = Factory(:user)
    template.stub!(:current_user).and_return(@user)
    @pitches = [active_pitch, active_pitch]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user,
                                                              :pitch => pitch,
                                                              :purchase => nil) }
    @spotus_donation = Factory(:spotus_donation, :user => @user, :amount => 1, :purchase => nil)
    @purchase = Purchase.new(:user => @user, :donations => @donations,
                             :spotus_donation => @spotus_donation)
    assigns[:donations] = @donations
    assigns[:purchase]  = @purchase
  end

  describe "PayPal" do
    it "has a Pay with PayPal section" do
      do_render
      template.should have_tag("h3", "Pay With PayPal")
      template.should have_tag("form[action=?]", PAYPAL_POST_URL) do
        with_tag("input[name='cmd'][value=?]", "_cart")
        with_tag("input[name='upload'][value=?]", "1")
        with_tag("input[name='business'][value=?]", PAYPAL_EMAIL)
        with_tag("input[name='return'][value=?]", paypal_return_myspot_purchases_url)
      end
    end
    it "includes all donations as line items" do
      do_render
      @donations.each do |donation|
        template.should have_tag("input[type='hidden'][value=?]", "PITCH: #{donation.pitch.headline}")
        template.should have_tag("input[type='hidden'][value=?]", "#{donation.amount}")
      end
    end
    it "includes the Spot.Us donation" do
      do_render
      template.should have_tag("input[name='item_name_#{@donations.size + 1}'][value=?]", "Support Spot.Us")
      template.should have_tag("input[name='amount_#{@donations.size + 1}'][value=?]", @spotus_donation.amount)
    end
  end

  it "should have a form to create a purchase" do
    do_render
    template.should have_form_posting_to(myspot_purchases_path)
  end

  it "should fields for a credit card" do
    do_render
    template.should have_form_posting_to(myspot_purchases_path)
    template.should have_text_field_for(:purchase_first_name)
    template.should have_text_field_for(:purchase_last_name)
    template.should have_text_field_for(:purchase_credit_card_number)
    template.should have_text_field_for(:purchase_credit_card_year)
    template.should have_text_field_for(:purchase_credit_card_month)
    template.should have_text_field_for(:purchase_verification_value)
    template.should have_text_field_for(:purchase_address1)
    template.should have_text_field_for(:purchase_address2)
    template.should have_text_field_for(:purchase_city)
    template.should have_text_field_for(:purchase_state)
    template.should have_text_field_for(:purchase_zip)
    template.should have_tag('select[name = ?]', 'purchase[credit_card_type]')
  end

  it 'should render' do
    do_render
  end

  it "should display any available errors" do
    @purchase.first_name = nil
    violated "need purchase validation errors" if @purchase.valid?
    template.should_receive(:content_for).with(:error).once
    do_render
    template.should have_tag('.fieldWithErrors')
  end

  def do_render
    render 'myspot/purchases/new'
  end
end
