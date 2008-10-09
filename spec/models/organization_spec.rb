require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Organization do
  describe "on create" do
    it "sends email for news org on create" do
      user = Factory.build(:organization)
      Mailer.should_receive(:deliver_organization_signup_notification).with(user)
      Mailer.should_receive(:deliver_news_org_signup_request).with(user)
      user.save!
    end
    
    it "should set the status column to 'needs_approval'" do
      user = Factory(:organization)
      user.status.should == "needs_approval"
    end
  end
  
  describe "on approval" do
    before(:each) do
      @user = Factory(:organization)
    end

    it "sends email with the password and indicates they were approved" do
      Mailer.should_receive(:deliver_organization_approved_notification).with(@user)
      @user.approve!
    end
    
    it "should set the status to approved" do
      @user.approve!
      @user.status.should == 'approved'
    end
  end
end