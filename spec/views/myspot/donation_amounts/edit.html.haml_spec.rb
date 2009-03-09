require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/donation_amounts/edit' do
  before do
    @user = Factory(:user)
    template.stub!(:current_user).and_return(@user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user,
                                                              :pitch => pitch) }
    @spotus_donation = Factory(:spotus_donation)
    @group = Factory(:group)
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
    @donations.stub!(:errors).and_return(["oh hai"])
    assigns[:donations] = @donations
    template.stub!(:content_for)
    template.should_receive(:content_for).with(:error).at_least(:once)
    do_render
  end

  it "doesn't display the group selector if no groups exist" do
    assigns[:donations] = @donations
    Group.stub!(:all).and_return([])
    do_render
    response.should_not have_tag("select[name=?]", "donation_amounts[#{@donations.first.id}][group_id]")
  end
  it "displays the group selector with each group listed" do
    assigns[:donations] = @donations
    Group.stub!(:all).and_return([@group])
    do_render
    response.should have_tag("select[name=?]", "donation_amounts[#{@donations.first.id}][group_id]") do
      with_tag("option[value=?]", @group.id, @group.name)
    end
  end

  def do_render
    render 'myspot/donation_amounts/edit'
  end
end
