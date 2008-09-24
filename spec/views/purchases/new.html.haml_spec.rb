require File.dirname(__FILE__) + "/../../spec_helper"

describe 'purchases/new' do
  before do
    @user = Factory(:user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user,
                                                              :pitch => pitch) }
    @purchase = Purchase.new(:user => @user, :donations => @donations)
    assigns[:donations] = @donations
    assigns[:purchase]  = @purchase
  end

  it "should have a form to create a purchase" do
    do_render
    template.should have_form_posting_to(purchase_path)
  end

  it "should fields for a credit card" do
    do_render
    template.should have_form_posting_to(purchase_path)
    template.should have_text_field_for(:purchase_first_name)
    template.should have_text_field_for(:purchase_last_name)
    template.should have_text_field_for(:purchase_credit_card_number)
    template.should have_text_field_for(:purchase_credit_card_year)
    template.should have_text_field_for(:purchase_credit_card_month)
    template.should have_text_field_for(:purchase_credit_card_type)
    template.should have_text_field_for(:purchase_verification_value)
    template.should have_text_field_for(:purchase_address1)
    template.should have_text_field_for(:purchase_address2)
    template.should have_text_field_for(:purchase_city)
    template.should have_text_field_for(:purchase_state)
    template.should have_text_field_for(:purchase_zip)
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
    render 'purchases/new'
  end
end
