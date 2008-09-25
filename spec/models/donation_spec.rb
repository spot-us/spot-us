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

  describe "creating" do
    it "is creatable by user" do
      Donation.createable_by?(Factory(:user)).should be
    end

    it "is not createable if not logged in" do
      Donation.createable_by?(nil).should_not be_true
    end
  end

  describe "editing" do
    before(:each) do
      @donation = Factory(:donation)
    end

    it "is editable by its owner" do
      @donation.editable_by?(@donation.user).should be
    end

    it "is not editable by a stranger" do
      @donation.editable_by?(Factory(:user)).should_not be_true
    end

    it "is not editable if not logged in" do
      @donation.editable_by?(nil).should_not be_true
    end
  end

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

  it "should not allow a paid donation to be modified" do
    donation = Factory(:donation, :paid => true)
    donation.amount = (donation.amount_in_cents + 1).to_dollars
    donation.should_not be_valid
    donation.should have(1).error_on(:base)
  end

  it "should allow an unpaid donation to be marked as paid" do
    donation = Factory(:donation, :paid => false)
    donation.paid = true
    donation.should be_valid
  end
end

