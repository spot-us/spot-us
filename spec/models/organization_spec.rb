require File.dirname(__FILE__) + '/../spec_helper'

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

  describe "named scopes" do
    before(:each) do
      @user1 = Factory(:organization)
      @user2 = Factory(:organization)
      @user3 = Factory(:organization)
      @user4 = Factory(:organization)
    end

    describe "when unapproved" do
      it "should return only a list of unapproved news orgs" do
        @user2.status.should == "needs_approval"
        @user2.approve!
        @user4.approve!
        User.unapproved_news_orgs.should == [@user1, @user3]
      end
    end

    describe "when approved" do
      it "should return only a list of approved news orgs" do
        @user2.approve!
        @user4.approve!
        User.approved_news_orgs.should == [@user2, @user4]
      end
    end
  end
end
