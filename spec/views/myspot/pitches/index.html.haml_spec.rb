require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/pitches/index' do
  before do
    @user = Factory(:user)
    Factory(:pitch, :user => @user)
    Factory(:pitch, :user => @user)
    Factory(:pitch, :user => @user)
    assigns[:pitches] = @user.pitches
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'myspot/pitches/index'
  end
end
