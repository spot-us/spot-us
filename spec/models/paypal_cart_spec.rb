require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaypalCart do
  describe "validations" do
    it "requires a user" do
      PaypalCart.new.should have(1).error_on(:user)
    end
    it "belongs to a user" do
      PaypalCart.new.should respond_to(:user)
    end
    it "has many donations" do
      PaypalCart.new.should respond_to(:donations)
    end
    it "has one spotus_donation" do
      PaypalCart.new.should respond_to(:spotus_donation)
    end
  end

  describe ".create_from_purchase" do
    before do
      @purchase = Factory(:purchase)
    end
    it "gets the purchase's donations" do
      PaypalCart.create_from_purchase(@purchase).donations.should == @purchase.donations
    end
    it "gets the purchase's spotus_donation" do
      PaypalCart.create_from_purchase(@purchase).spotus_donation.should == @purchase.spotus_donation
    end
    it "gets the purchase's user" do
      PaypalCart.create_from_purchase(@purchase).user.should == @purchase.user
    end
  end
end
