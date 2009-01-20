require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SpotusDonation do
  before do
    @user = Factory(:user)
    @donation1 = Factory(:donation, :user => @user, :amount => 10)
    @donation2 = Factory(:donation, :user => @user, :amount => 10)
  end

  describe "#unpaid" do
    before do
      @spotus_donation = Factory(:spotus_donation, :user => @user,
                                 :purchase          => nil,
                                 :amount_in_dollars => 1)
    end

    it "should only return donations with a nil purchase_id" do
      @user.spotus_donations.unpaid.should include(@spotus_donation)
    end
  end

  it "should set the default amount to 10% of the user's unpaid donations" do
    @user.spotus_donations.build.amount_in_cents.should == 200
  end

  it "should round the default amount to the nearest dollar" do
    donation = Factory(:donation, :user => @user, :amount => 54)
    # user's total unpaid donations now == $74
    @user.spotus_donations.build.amount_in_cents.should == 700
  end

  it "should allow the user to donate more than 10%" do
    spotus_donation = @user.spotus_donations.build(:amount_in_cents => 300)
    spotus_donation.amount_in_cents.should == 300
  end

  it "should take an amount in dollars and use it to set amount_in_cents" do
    spotus_donation = @user.spotus_donations.build(:amount_in_dollars => 3)
    spotus_donation.amount_in_cents.should == 300
  end

end
