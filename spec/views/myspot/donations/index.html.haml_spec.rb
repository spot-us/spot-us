require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/donations/index' do
  before do
    @user = Factory(:user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user, :pitch => pitch) }
    @user.stub!(:has_spotus_donation?).and_return(true)
    @user.stub!(:last_paid_spotus_donation).and_return(Factory(:spotus_donation))
    @user.stub!(:paid_spotus_donations_sum).and_return(35)
    assigns[:donations] = @donations
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  it "should render a row for the user's spotus_donation" do
    do_render
    response.should have_tag("img[src*=support_spotus.png]")
  end

  def do_render
    render 'myspot/donations/index'
  end
end
