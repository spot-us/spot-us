require File.dirname(__FILE__) + '/../spec_helper'

# dummy class on which to test, just uses users table to avoid errors
class TestDollars < ActiveRecord::Base
  set_table_name "users"
  has_dollar_field(:amount)
end

describe "dollars library" do
  describe "normalization" do
    it "handles commas" do
      d = TestDollars.new :amount => "1,000"
      d.amount.should == "1000.0"
    end

    it "allows decimal" do
      d = TestDollars.new :amount => "1000.00"
      d.amount.should == "1000.0"
    end
        
    it "handles regular number" do
      d = TestDollars.new :amount => "1000"
      d.amount.should == "1000.0"
    end

    it "handles a non-string number" do
      d = TestDollars.new :amount => 1000
      d.amount.should == "1000.0"
    end
    
    it "ignores dollar sign" do
      d = TestDollars.new :amount => "$1000"
      d.amount.should == "1000.0"
    end
    
    it "handles combo of dollar sign and comma" do
      d = TestDollars.new :amount => "$1,000"
      d.amount.should == "1000.0"
    end

    it "handles gunk" do
      d = TestDollars.new :amount => "#%$^%&()1000"
      d.amount.should == "1000.0"
    end
  end
end
