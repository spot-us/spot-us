require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  table_has_columns(Donation, :integer, "user_id")
  table_has_columns(Donation, :integer, "pitch_id")
  table_has_columns(Donation, :integer, "amount_in_cents")
  table_has_columns(Donation, :string, "status")

  # TODO:  Need to figure out how to make these work in spec_helper for these cases.
  # requires_presence_of Donation, :user_id
  # # requires_presence_of Donation, :pitch_id
  # requires_presence_of Donation, :amount

  it { Donation.should belong_to(:user) }
  it { Donation.should belong_to(:pitch) }
  it { Donation.should belong_to(:purchase) }
  
  has_dollar_field(Donation, :amount)
  
  describe "when creating a donation" do
    it "should require user to be logged in" do
      Donation.createable_by?(nil).should_not be_true
    end

    describe "as a citizen or reporter" do
      describe "should be invaild and add an error" do
        it "if the pitch is fully funded" do
          pitch = Factory(:pitch, :requested_amount => 100, :user => Factory(:user))
          Factory(:donation, :pitch => pitch, :amount => 20, :status => 'paid')
          Factory(:donation, :pitch => pitch, :amount => 20, :status => 'paid')
          Factory(:donation, :pitch => pitch, :amount => 20, :status => 'paid')
          Factory(:donation, :pitch => pitch, :amount => 20, :status => 'paid')
          Factory(:donation, :pitch => pitch, :amount => 20, :status => 'paid')
          pitch.reload

          donation = Factory.build(:donation, :pitch => pitch, :user => Factory(:user), :amount => 1, :status => 'paid')
          donation.should_not be_valid
          donation.errors.full_messages.first.should =~ /fully funded/
          donation.should have(1).error_on(:base)
        end

         it "if user's total donations + the new donation is >= 20% of the pitches requested amount" do
           user = Factory(:user)
           pitch = Factory(:pitch, :requested_amount => 1000, :user => user)
           Factory(:donation, :pitch => pitch, :user => user, :amount => 100, :status => 'paid')
           donation = Factory.build(:donation, :pitch => pitch, :user => user, :amount => 101)
           pitch.reload
           donation.should_not be_valid
           donation.errors.full_messages.first.should =~ /20/
           donation.should have(1).error_on(:base)
         end
      end
    end
    
    describe "as a news organization" do
      it "allows donation of  an arbitrary amount" do
        organization = Factory(:organization)
        p = Factory(:pitch, :requested_amount => 100)
        d = Factory.build(:donation, :pitch => p, :user => organization, :amount => 100)
        d.should be_valid
      end
      
      it "still guards against donating more than requested amount" do
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
    donation.should have(1).error_on(:amount_in_cents)
  end

  it "should not allow zero for a donation" do
    donation = Factory.build(:donation, :amount => 0)
    donation.should_not be_valid
    donation.should have(1).error_on(:amount_in_cents)
  end

  it "should not allow a paid donation to be modified" do
    donation = Factory(:donation, :status => 'paid')
    donation.amount = (donation.amount_in_cents + 1).to_dollars
    donation.should_not be_valid
    donation.should have(1).error_on(:base)
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
    it "should have a state of unpaid when it is first created" do
      pending
    end
    
    it "should have a state of paid when it has been paid" do
      pending
    end
    
    it "should have a state of refunded when a refund has been issued" do
      pending
    end
  end
  
  describe "news org funding a donation" do
    it "should allow a news org to fully fund a pitch" do
      pending
    end
    
    it "should allow a news org to match funding if the pitch is less than 50% funded" do
      pending
    end
    
  end
end

