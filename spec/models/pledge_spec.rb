require File.dirname(__FILE__) + '/../spec_helper'

describe Pledge do
  table_has_columns(Pledge, :integer, "user_id")
  table_has_columns(Pledge, :integer, "tip_id")
  table_has_columns(Pledge, :integer, "amount_in_cents")

  requires_presence_of Pledge, :user_id
  requires_presence_of Pledge, :tip_id
  requires_presence_of Pledge, :amount

  it { Factory(:pledge).should belong_to(:user) }
  it { Factory(:pledge).should belong_to(:tip) }

  has_dollar_field(Pledge, :amount)
end

