require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  table_has_columns(Donation, :integer, "user_id")
  table_has_columns(Donation, :integer, "pitch_id")

  requires_presence_of Donation, :user_id
  requires_presence_of Donation, :pitch_id

  it { Factory(:donation).should belong_to(:user) }
  it { Factory(:donation).should belong_to(:pitch) }
end

