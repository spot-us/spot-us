require File.dirname(__FILE__) + '/../spec_helper'

describe Affiliation do
  table_has_columns(Affiliation, :integer, "pitch_id")
  table_has_columns(Affiliation, :integer, "tip_id")

  requires_presence_of Affiliation, :pitch_id
  requires_presence_of Affiliation, :tip_id

  it { Factory(:affiliation).should belong_to(:pitch) }
  it { Factory(:affiliation).should belong_to(:tip) }

  describe "validation" do
    before do
      @tip = Factory(:tip)
      @pitch = Factory(:pitch)
      @affiliation = Affiliation.new(:tip => @tip, :pitch => @pitch)
    end

    it "requires pitch to be unique to a tip" do
      Factory(:affiliation, :tip => @tip, :pitch => @pitch)
      @affiliation.should_not be_valid
      @affiliation.should have(1).error_on(:pitch_id)
    end
  end

  describe "#createable_by?" do
    before do
      @reporter = Factory(:reporter)
      @pitch = Factory(:pitch, :user => @reporter)
      @tip = Factory(:tip)
    end

    it "allows the pitch's reporter to create an affiliation" do
      Affiliation.new(:pitch => @pitch).createable_by?(@reporter).should be_true
    end
    it "allows an admin to create an affiliation" do
      Affiliation.new(:pitch => @pitch).createable_by?(Factory(:admin)).should be_true
    end
    it "requires a pitch to create an affiliation" do
      Affiliation.new(:pitch => nil).createable_by?(@reporter).should be_false
    end
    it "returns false otherwise" do
      Affiliation.new(:pitch => @pitch).createable_by?(Factory(:citizen)).should be_false
    end
  end

  describe "editing" do
    before(:each) do
      @affiliation = Factory(:affiliation)
    end

    it "is not editable by its owner" do
      @affiliation.editable_by?(@affiliation.pitch.user).should_not be_true
    end

    it "is not editable by a stranger" do
      @affiliation.editable_by?(Factory(:user)).should_not be_true
    end

    it "is not editable if not logged in" do
      @affiliation.editable_by?(nil).should_not be_true
    end
  end
end

