require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TopicMembership do
  it { TopicMembership.should belong_to(:topic) }
  it { TopicMembership.should belong_to(:member) }
end
