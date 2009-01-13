require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  it "should give us the current balance" do
    user = Factory(:user)
    Factory(:donation, :user => user, :amount => 10)
    stub!(:current_user).and_return(user)
    current_balance.to_dollars.should == "10.0"
  end

  it "should add correctly" do
    user = Factory(:user)
    Factory(:donation, :user => user, :amount => 10)
    Factory(:donation, :user => user, :amount => 10)
    stub!(:current_user).and_return(user)
    current_balance.to_dollars.should == "20.0"
  end

  it "should return 0 when there are no unpaid donations" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    current_balance.should == 0
  end

  it "should display credits only message when no updaid donations but there are credits" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:credit, :amount => 25, :user => user)
    header_display_message.should =~ /You have \$25.00 in credit/
  end

  it "should display credits and donations message when have both" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:credit, :amount => 25, :user => user)
    Factory(:donation, :amount => 25, :user => user)
    header_display_message.should =~ /credits to use toward your donations/
  end

  it "should display donations message when only have donations and no credits" do
    user = Factory(:user)
    stub!(:current_user).and_return(user)
    Factory(:donation, :amount => 25, :user => user)
    header_display_message.should =~ /to fund your donations/
   end

end
