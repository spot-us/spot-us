require File.dirname(__FILE__) + '/../spec_helper'

describe Tip do
  table_has_columns(Tip, :text,     "short_description")
  table_has_columns(Tip, :boolean,  "contract_agreement")
  
  requires_presence_of Tip, :short_description
  requires_presence_of Tip, :user
  requires_presence_of Tip, :keywords
  requires_presence_of Tip, :pledge_amount

  it {Factory(:tip).should have_many(:supporters)}

  it "returns true on #tip?" do
    Factory(:tip).should be_a_tip
  end
  
  it "returns false on #pitch?" do
    Factory(:tip).should_not be_a_pitch
  end

  it "requires location to be a valid LOCATION" do
    Factory.build(:tip, :location => LOCATIONS.first).should be_valid
    Factory.build(:tip, :location => "invalid").should_not be_valid
  end

  it "has a virtual accessor named pledge_amount" do
    Factory.build(:tip).should respond_to(:pledge_amount)
    Factory.build(:tip).should respond_to(:pledge_amount=)
  end

  it { Factory(:tip).should have_many(:pledges) }

  describe "a new tip with a pledge amount" do
    before(:each) do
      @tip = Factory.build(:tip, :pledge_amount => 1234)
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
