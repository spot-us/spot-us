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
  it {Factory(:tip).should have_many(:comments)}

  describe "editable_by?" do
    it "allows editing of unpledged tip by owner" do
      user = Factory(:citizen)
      t = Factory :tip, :user => user
      t.editable_by?(user).should be_true
    end

    it "disallows editing of tip with a pledge and the user is not an admin" do
      user = Factory(:citizen)
      t = Factory :tip, :user => user
      p = Factory :pledge, :tip => t
      t.reload
      t.editable_by?(user).should be_false
    end

    it "allows editing by admin" do
      user = Factory(:admin)
      t = Factory :tip, :user => user
      t.reload
      t.editable_by?(user).should be_true
    end

    it "allows editing by admin even if tip has pledges" do
      user = Factory(:admin)
      t = Factory :tip, :user => user
      p = Factory :pledge, :tip => t
      t.reload
      t.editable_by?(user).should be_true
    end

    it "disallows editing of nil user" do
      user = Factory(:citizen)
      t = Factory :tip, :user => user
      p = Factory :pledge, :tip => t
      t.reload
      t.editable_by?(nil).should be_false
    end
  end

  describe "most_pledged" do
    it "should return the most pledged first" do
      tip1 = Factory :tip
      pledge1 = Factory :pledge, :tip => tip1, :amount => 5
      tip2 = Factory :tip
      pledge2 = Factory :pledge, :tip => tip2, :amount => 10
      Tip.most_pledged.should == [tip2, tip1]
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

  it "has a virtual accessor named pledge_amount" do
    Factory.build(:tip).should respond_to(:pledge_amount)
    Factory.build(:tip).should respond_to(:pledge_amount=)
  end

  it { Factory(:tip).should have_many(:pledges) }

  describe "a new tip with a pledge amount" do
    before(:each) do
      user = Factory(:user)
      @tip = Factory.build(:tip, :pledge_amount => 1234, :user => user, :network => Factory(:network))
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

  it "should return 0 when no pledges" do
    tip = Factory(:tip, :pledge_amount => 0)
    tip.total_amount_pledged.should == 0.0
  end

  describe "destroy" do
    it "should set the deleted_at column" do
      tip = Factory(:tip)
      tip.should be
      tip.destroy
      Tip.find(:all).should_not include(tip)
      Tip.find_with_deleted(:all).should include(tip)
    end

    it "should delete associated pledges" do
      tip = Factory(:tip)
      p = Factory(:pledge, :tip=> tip, :amount => 3000)
      p2 = Factory(:pledge, :tip=> tip, :amount => 2)
      p3 = Factory(:pledge, :tip=> tip, :amount => 1)
      tip.reload
      tip.destroy
      Pledge.find(:all).should be_empty
      Pledge.find_with_deleted(:all).should include(p)
    end
  end
end

