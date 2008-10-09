require File.dirname(__FILE__) + "/../../../spec_helper"

describe '/admin/tips/index' do
  it "should render" do
    user = Factory(:admin)
    template.stub!(:current_user).and_return(@user)
    tips = [Factory(:tip), Factory(:tip)]
    assigns[:tips] = tips
    render '/admin/tips/index'
  end
end