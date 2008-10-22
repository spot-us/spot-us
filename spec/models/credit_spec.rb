require File.dirname(__FILE__) + '/../spec_helper'

describe Credit do
  table_has_columns(Credit, :integer, "user_id")
  table_has_columns(Credit, :integer, "amount_in_cents")
  table_has_columns(Credit, :string, "description")
  table_has_columns(Credit, :boolean, "used")
  
end