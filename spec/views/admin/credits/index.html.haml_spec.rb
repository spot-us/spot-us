require File.dirname(__FILE__) + "/../../../spec_helper"

describe '/admin/credits/index' do  
  it "should render" do
    user = Factory(:admin)
    template.stub!(:current_user).and_return(@user)
    credits = [Factory(:credit), Factory(:credit)]
    assigns[:credits] = credits
    render '/admin/credits/index'
  end
end