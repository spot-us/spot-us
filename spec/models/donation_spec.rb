require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  table_has_columns(Donation, :integer, "user_id")
  table_has_columns(Donation, :integer, "pitch_id")
  table_has_columns(Donation, :integer, "amount_in_cents")
  table_has_columns(Donation, :boolean, "paid")

  requires_presence_of Donation, :user_id
  requires_presence_of Donation, :pitch_id
  requires_presence_of Donation, :amount

  it { Donation.should belong_to(:user) }
  it { Donation.should belong_to(:pitch) }
  it { Donation.should belong_to(:purchase) }

  has_dollar_field(Donation, :amount)

  describe "Donation.unpaid" do
    before(:each) do
      Factory(:donation, :paid => true)
      Factory(:donation, :paid => false)
      @donations = Donation.unpaid
    end

    it "should not return paid donations" do
      @donations.select(&:paid?).should == []
    end

    it "should return all unpaid donations" do
      @donations.reject(&:paid?).should_not == []
    end
  end

  it "should not allow negative values for donations" do
    donation = Factory.build(:donation, :amount => -1)
    donation.should_not be_valid
    donation.should have(1).error_on(:amount_in_cents)
  end

  it "should not allow zero for a donation" do
    donation = Factory.build(:donation, :amount => 0)
    donation.should_not be_valid
    donation.should have(1).error_on(:amount_in_cents)
  end
end

