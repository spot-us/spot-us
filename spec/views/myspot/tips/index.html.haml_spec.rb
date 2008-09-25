require File.dirname(__FILE__) + "/../../../spec_helper"

describe 'myspot/tips/index' do
  before do
    @user = Factory(:user)
    Factory(:tip, :user => @user)
    Factory(:tip, :user => @user)
    Factory(:tip, :user => @user)
    assigns[:tips] = @user.tips
    template.stub!(:current_user).and_return(@user)
  end

  it 'should render' do
    do_render
  end

  def do_render
    render 'myspot/tips/index'
  end
end
