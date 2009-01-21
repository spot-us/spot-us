require File.dirname(__FILE__) + "/../../../spec_helper"

describe '/admin/credits/index' do  
  it "should render" do
    user = Factory(:admin)
    template.stub!(:current_user).and_return(@user)
    users = [Factory(:user), Factory(:user)]
    credits = [Factory(:credit, :user => users[0]), Factory(:credit, :user => users[1])]
    assigns[:credit] = Credit.new
    assigns[:credits] = credits
    assigns[:users] = users
    render '/admin/credits/index'
  end
end
