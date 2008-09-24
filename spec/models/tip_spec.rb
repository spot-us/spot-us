require File.dirname(__FILE__) + '/../spec_helper'

describe Tip do
  table_has_columns(Tip, :text,     "short_description")
  table_has_columns(Tip, :boolean,  "contract_agreement")
  
  requires_presence_of Tip, :short_description
  requires_presence_of Tip, :keywords
  
  it "requires location to be a valid LOCATION" do
    Factory.build(:tip, :location => LOCATIONS.first).should be_valid
    Factory.build(:tip, :location => "invalid").should_not be_valid
  end

  describe "to support STI" do
    it "descends from NewItem" do
      Tip.ancestors.include?(NewsItem)
    end
  end
  
end