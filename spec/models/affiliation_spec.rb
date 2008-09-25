require File.dirname(__FILE__) + '/../spec_helper'

describe Affiliation do
  table_has_columns(Affiliation, :integer, "pitch_id")
  table_has_columns(Affiliation, :integer, "tip_id")

  requires_presence_of Affiliation, :pitch_id
  requires_presence_of Affiliation, :tip_id

  it { Factory(:affiliation).should belong_to(:pitch) }
  it { Factory(:affiliation).should belong_to(:tip) }

  describe "creating" do
    it "is creatable by reporter" do
      Affiliation.createable_by?(Factory(:reporter)).should be
    end

    it "is not creatable by user" do
      Affiliation.createable_by?(Factory(:user)).should_not be
    end

    it "is not createable if not logged in" do
      Affiliation.createable_by?(nil).should_not be_true
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

