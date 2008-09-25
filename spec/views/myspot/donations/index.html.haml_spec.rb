require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/donations/index' do
  before do
    @user = Factory(:user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user, :pitch => pitch) }
    assigns[:donations] = @donations
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'myspot/donations/index'
  end
end
