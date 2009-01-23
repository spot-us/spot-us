require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/donation_amounts/edit' do
  before do
    @user = Factory(:user)
    template.stub!(:current_user).and_return(@user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user,
                                                              :pitch => pitch) }
    @spotus_donation = Factory(:spotus_donation)
    template.stub!(:unpaid_donations).and_return(@donations)
    template.stub!(:spotus_donation).and_return(@spotus_donation)
  end

  it 'should render' do
    do_render
  end

  it "should have a form to update the user's donations" do
    do_render
    template.should have_tag('form[method="post"][action=?]', myspot_donations_amounts_path) do
      with_tag('input[name="_method"][value="put"]')
    end
  end

  it "should have a text field tag to change the amount of each donation" do
    do_render
    @donations.each do |donation|
      template.should have_tag("input#?", "donation_amounts_#{donation.id}_amount")
    end
  end

  it "should display the spot.us donation field" do
    do_render
    template.should have_tag('input[type="text"][name=?]', "spotus_donation_amount")

  end

  it "should display error messages when available" do
    @user.stub!(:errors).and_return(["oh hai"])
    template.stub!(:content_for)
    template.should_receive(:content_for).with(:error).at_least(:once)
    do_render
  end

  def do_render
    render 'myspot/donation_amounts/edit'
  end
end
