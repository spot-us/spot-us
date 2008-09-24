require File.dirname(__FILE__) + "/../../spec_helper"

describe 'donations/index' do
  before do
    @user = Factory(:user)
    @pitches = [Factory(:pitch), Factory(:pitch)]
    @donations = @pitches.collect {|pitch| Factory(:donation, :user => @user,
                                                              :pitch => pitch) }
    assigns[:donations] = @donations
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'donations/index'
  end
end
