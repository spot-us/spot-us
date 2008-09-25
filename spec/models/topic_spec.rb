require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Topic do
  table_has_columns Topic, :string, :name

  it { Topic.should have_many(:topic_memberships) }

  requires_presence_of Topic, :name

  it "should require a unique name" do
    topic = Factory(:topic)
    other = Factory.build(:topic, :name => topic.name)
    other.should_not be_valid
    other.should have(1).error_on(:name)
  end
end
