require File.dirname(__FILE__) + '/../spec_helper'

describe Affiliation do
  table_has_columns(Affiliation, :integer, "pitch_id")
  table_has_columns(Affiliation, :integer, "tip_id")

  requires_presence_of Affiliation, :pitch_id
  requires_presence_of Affiliation, :tip_id

  it { Factory(:affiliation).should belong_to(:pitch) }
  it { Factory(:affiliation).should belong_to(:tip) }
end

