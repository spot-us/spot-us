require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  
  it "should give us the current balance" do
    user = Factory(:user)
    donation = Factory(:donation, :user => user, :amount => 10)
    stub!(:current_user).and_return(user)
    current_balance.should == "10.0"
  end
  
  it "should return 0 when there are no unpaid donations" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    current_balance.should == 0
  end  
end
