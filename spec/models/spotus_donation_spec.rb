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
                                 :amount            => 1)
    end

    it "should only return donations with a nil purchase_id" do
      @user.spotus_donations.unpaid.should include(@spotus_donation)
    end
  end

  describe "#paid" do
    before do
      @spotus_donation = Factory(:spotus_donation, :user => @user,
                                                   :purchase => Factory(:purchase),
                                                   :amount => 1)
    end

    it "should only return donations with a purchase_id" do
      @user.spotus_donations.paid.should include(@spotus_donation)
    end
  end

  it "should set the default amount to 10% of the user's unpaid donations" do
    @user.spotus_donations.build.amount.should == 2
  end

  it "should round the default amount to the nearest dollar" do
    donation = Factory(:donation, :user => @user, :amount => 54)
    # user's total unpaid donations now == $74
    @user.spotus_donations.build.amount.should == BigDecimal.new("7.0")
  end

  it "should allow the user to donate more than 10%" do
    spotus_donation = @user.spotus_donations.build(:amount => 3)
    spotus_donation.amount.should == BigDecimal.new("3.0")
  end

end
