require File.dirname(__FILE__) + '/../spec_helper'

describe Credit do
  table_has_columns(Credit, :integer, "user_id")
  table_has_columns(Credit, :decimal, "amount")
  table_has_columns(Credit, :string, "description")
  
  it { Credit.should belong_to(:user) }
  requires_presence_of Credit, :amount
  requires_presence_of Credit, :description
  requires_presence_of Credit, :user_id
  
end
