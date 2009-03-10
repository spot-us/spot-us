require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  table_has_columns(Donation, :integer, "user_id")
  table_has_columns(Donation, :integer, "pitch_id")
  table_has_columns(Donation, :decimal, "amount")
  table_has_columns(Donation, :string, "status")

  # TODO:  Need to figure out how to make these work in spec_helper for these cases.
  # requires_presence_of Donation, :user_id
  # # requires_presence_of Donation, :pitch_id
  # requires_presence_of Donation, :amount

  it { Donation.should belong_to(:user) }
  it { Donation.should belong_to(:pitch) }
  it { Donation.should belong_to(:purchase) }
  it { Donation.should belong_to(:group) }

  describe "when creating a donation" do
    it "should require user to be logged in" do
      Donation.createable_by?(nil).should_not be_true
    end

    describe "as a citizen or reporter" do
      describe "should be valid" do
        before do
          @pitch = active_pitch(:requested_amount => 100, :user => Factory(:user))
        end

        it "if the pitch needs funds" do
          donation = Factory.build(:donation,
                                   :pitch => @pitch,
                                   :user => Factory(:user),
                                   :amount => 10,
                                   :status => 'paid')
          donation.should be_valid
        end

        it "if max donation amount < 20% of funding needed" do
          donator =  Factory(:user)
          donation = Factory(:donation,
                             :pitch => @pitch,
                             :user => donator,
                             :amount => 10,
                             :status => 'paid')
          second_donation = Factory.build(:donation,
                                   :pitch => @pitch,
                                   :user => donator,
                                   :amount => 5,
                                   :status => 'paid')

          second_donation.should be_valid
        end

      end

      describe "should be invalid and add an error" do
        it "if the pitch is fully funded" do
          pitch = active_pitch(:requested_amount => 100, :user => Factory(:user))
          pitch.stub!(:fully_funded?).and_return(true)

          donation = Factory.build(:donation, :pitch => pitch, :user => Factory(:user), :amount => 1, :status => 'paid')
          donation.should_not be_valid
          donation.errors.full_messages.first.should =~ /fully funded/
          donation.should have(1).error_on(:base)
        end

         it "if user's total donations + the new donation is >= 20% of the pitch's requested amount" do
           user = Factory(:user)
           pitch = active_pitch(:requested_amount => 1000, :user => user)
           pitch.stub!(:user_can_donate_more?).and_return(false)
           donation = Factory.build(:donation, :pitch => pitch, :user => user, :amount => 101)
           donation.should_not be_valid
           donation.errors.full_messages.first.should =~ /20/
           donation.should have(1).error_on(:base)
         end
      end
    end

    describe "as a news organization" do
      it "allows donation of  an arbitrary amount" do
        organization = Factory(:organization)
        p = active_pitch(:requested_amount => 100)
        d = Factory(:donation, :pitch => p, :user => organization, :amount => 100)
        d.should be_valid
      end
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

  describe "Donation.from_organizations" do
    before do
      @organization = Factory(:organization)
      @citizen = Factory(:citizen)
      @pitch = active_pitch(:requested_amount => 1000)
      Factory(:donation, :user => @organization, :amount => 100)
      Factory(:donation, :user => @citizen, :amount => 10)
    end

    it "should include the donating organization" do
      Donation.from_organizations.map(&:user).should include(@organization)
    end
    it "should not include the donating citizen" do
      Donation.from_organizations.map(&:user).should_not include(@citizen)
    end
  end

  describe "Donation.unpaid" do
    before(:each) do
      Factory(:donation, :status => 'paid')
      Factory(:donation, :status => 'unpaid')
      @donations = Donation.unpaid
    end

    it "should not return paid donations" do
      @donations.select(&:paid?).should == []
    end

    it "should return all unpaid donations" do
      @donations.reject(&:paid?).should_not == []
    end
  end

  describe "Donation.paid" do
    before(:each) do
      Factory(:donation, :status => 'paid')
      Factory(:donation, :status => 'unpaid')
      @donations = Donation.paid
    end

    it "should not return unpaid donations" do
      @donations.select(&:paid?).should_not == []
    end

    it "should return all paid donations" do
      @donations.reject(&:paid?).should == []
    end

  end

  it "should not allow negative values for donations" do
    donation = Factory.build(:donation, :amount => nil)
    donation.should_not be_valid
    donation.should have_at_least(1).error_on(:amount)
  end

  it "should not allow zero for a donation" do
    donation = Factory.build(:donation, :amount => 0)
    donation.should_not be_valid
    donation.should have_at_least(1).error_on(:amount)
  end

  it "should not allow a paid donation to be modified" do
    donation = Factory(:donation, :status => 'paid')
    donation.amount = (donation.amount + 1)
    donation.should_not be_valid
    donation.should have_at_least(1).error_on(:base)
  end

  it "should allow an unpaid donation to be marked as paid" do
    donation = Factory(:donation)
    donation.should be_unpaid
    donation.pay
    donation.should be_valid
  end

  describe "deleting a donation" do
    it "should be deletable by the owner of the unpaid donation" do
      user = Factory(:user)
      donation = Factory(:donation, :user => user, :status => 'unpaid')
      donation.deletable_by?(user).should be_true
    end

    it "should not be able to delete a paid donation" do
      user = Factory(:user)
      donation = Factory(:donation, :user => user, :status => 'paid')
      donation.deletable_by?(user).should be_false
    end

    it "should be deletable by an admin" do
      admin = Factory(:admin)
      donation = Factory(:donation, :user => Factory(:user), :status => 'unpaid')
      donation.deletable_by?(admin).should be_true
    end

    it "should not be deleteable by a nil user" do
      donation = Factory(:donation, :user => Factory(:user), :status => 'unpaid')
      donation.deletable_by?(nil).should be_false
    end
  end

  describe "states of a donation" do
    before do
      @donation = Factory(:donation)
    end
    it "should have a state of unpaid when it is first created" do
      @donation.should be_unpaid
    end

    it "should have a state of paid when it has been paid" do
      @donation.pay!
      @donation.should be_paid
    end

    it "should have a state of refunded when a refund has been issued" do
      @donation.pay!
      @donation.refund!
      @donation.should be_refunded
    end

    it "should not allow a refund on an unpaid @donation" do
      lambda {
        @donation.refund!
      }.should raise_error
    end

    it "should send a thank you email when paid" do
      Mailer.should_receive(:deliver_user_thank_you_for_donating)
      Factory(:donation,
              :user => Factory(:user),
              :amount => 10,
              :status => 'unpaid').pay!
    end
  end

  describe "DEFAULT_AMOUNT" do
    it "should exist" do
      Donation::DEFAULT_AMOUNT.should == 25
    end
  end
end

