require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaypalTransaction do

  describe "validations" do
    it "requires a transaction id" do
      PaypalTransaction.new.should have(1).error_on(:txn_id)
    end
  end
end
