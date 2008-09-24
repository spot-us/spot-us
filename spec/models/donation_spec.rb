require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  table_has_columns(Donation, :integer, "user_id")
  table_has_columns(Donation, :integer, "pitch_id")
  table_has_columns(Donation, :integer, "amount_in_cents")
  table_has_columns(Donation, :boolean, "paid")

  requires_presence_of Donation, :user_id
  requires_presence_of Donation, :pitch_id
  requires_presence_of Donation, :amount_in_cents

  it { Donation.should belong_to(:user) }
  it { Donation.should belong_to(:pitch) }
  it { Donation.should belong_to(:purchase) }

  describe "Donation.unpaid" do
    before(:each) do
      Donation.destroy_all

      Factory(:donation, :paid => true)
      Factory(:donation, :paid => false)
      @donations = Donation.unpaid
    end

    it "should not return paid donations" do
      @donations.select(&:paid?).should be_empty
    end

    it "should return all unpaid donations" do
      @donations.reject(&:paid?).should_not be_empty
    end
  end
end

