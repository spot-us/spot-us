require File.dirname(__FILE__) + '/../spec_helper'

describe Pledge do
  table_has_columns(Pledge, :integer, "user_id")
  table_has_columns(Pledge, :integer, "tip_id")
  table_has_columns(Pledge, :decimal, "amount")

  requires_presence_of Pledge, :user_id
  requires_presence_of Pledge, :tip_id
  requires_presence_of Pledge, :amount

  it { Factory(:pledge).should belong_to(:user) }
  it { Factory(:pledge).should belong_to(:tip) }

  it "isn't valid if there is already a pledge for that tip and user" do
    pledge = Factory(:pledge)
    duplicate = Factory.build(:pledge, :tip_id => pledge.tip_id, :user_id => pledge.user_id)
    duplicate.should_not be_valid
    duplicate.should have(1).error_on(:tip_id)
  end

  it "requires an amount greater than 0" do
    Pledge.new(:amount => 0).should have(1).error_on(:amount)
  end

  describe "creating" do
    it "is creatable by user" do
      Pledge.createable_by?(Factory(:user)).should be
    end

    it "is not createable if not logged in" do
      Pledge.createable_by?(nil).should_not be_true
    end
  end

  describe "editing" do
    before(:each) do
      @pledge = Factory(:pledge)
    end

    it "is editable by its owner" do
      @pledge.editable_by?(@pledge.user).should be
    end

    it "is not editable by a stranger" do
      @pledge.editable_by?(Factory(:user)).should_not be_true
    end

    it "is not editable if not logged in" do
      @pledge.editable_by?(nil).should_not be_true
    end
  end
end

