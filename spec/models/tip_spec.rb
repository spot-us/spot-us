require File.dirname(__FILE__) + '/../spec_helper'

describe Tip do
  table_has_columns(Tip, :text,     "short_description")
  table_has_columns(Tip, :boolean,  "contract_agreement")
  
  requires_presence_of Tip, :short_description
  requires_presence_of Tip, :user
  requires_presence_of Tip, :pledge_amount

  it {Factory(:tip).should have_many(:supporters)}
  it {Factory(:tip).should have_many(:pledges)}
  it {Factory(:tip).should have_many(:affiliations)}
  it {Factory(:tip).should have_many(:pitches)}

  describe "edit guards" do
    it "allows editing of unpledged tip" do
      t = Factory :tip
      t.can_be_edited?.should be_false      
    end
    
    it "disallows editing of tip which has a pledge" do
      t = Factory :tip
      p = Factory :pledge, :tip => t
      t.reload
      t.can_be_edited?.should be_false      
    end    
  end
  
  describe "pledged to" do
    it "a new tip isn't pledged to" do
      # don't confuse this with the fact that an initial pledge amount can be set
      # this assertion refers to the pledges association collection (pledges by others)
      
      t = Factory :tip
      t.should_not be_pledged_to
    end
    
    it "is pledged to when there's pledges" do
      t = Factory :tip
      p = Factory :pledge, :tip => t
      t.reload
      t.should be_pledged_to
    end
  end

  describe "creating" do
    it "is creatable by user" do
      Tip.createable_by?(Factory(:user)).should be
    end

    it "is not createable if not logged in" do
      Tip.createable_by?(nil).should_not be_true
    end
  end

  it "returns true on #tip?" do
    Factory(:tip).should be_a_tip
  end
  
  it "returns false on #pitch?" do
    Factory(:tip).should_not be_a_pitch
  end

  it "requires location to be a valid LOCATION" do
    user = Factory(:user)
    Factory.build(:tip, :location => LOCATIONS.first, :user => user).should be_valid
    Factory.build(:tip, :location => "invalid", :user => user).should_not be_valid
  end

  it "has a virtual accessor named pledge_amount" do
    Factory.build(:tip).should respond_to(:pledge_amount)
    Factory.build(:tip).should respond_to(:pledge_amount=)
  end

  it { Factory(:tip).should have_many(:pledges) }

  describe "a new tip with a pledge amount" do
    before(:each) do
      user = Factory(:user)
      @tip = Factory.build(:tip, :pledge_amount => 1234, :user => user)
    end

    it "should build the first pledge on save" do
      @tip.save!
      @tip.reload.should_not be_nil
      pledge = @tip.pledges.first
      pledge.should_not be_nil
      pledge.should_not be_a_new_record
    end
  end

  describe "to support STI" do
    it "descends from NewItem" do
      Tip.ancestors.include?(NewsItem)
    end
  end
  
  it "returns all pledged money on total_amount_pledged" do
    tip = Factory(:tip)
    Factory(:pledge, :tip=> tip, :amount => 3000)
    Factory(:pledge, :tip=> tip, :amount => 2)
    Factory(:pledge, :tip=> tip, :amount => 1)
    
    tip.reload
    tip.total_amount_pledged.to_f.should == tip.pledges.map(&:amount).map(&:to_f).sum
  end
end
