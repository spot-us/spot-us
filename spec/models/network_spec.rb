require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Network do

  requires_presence_of Network, :name
  requires_presence_of Network, :display_name

  it "should only allow valid URL characters" do
    network = Network.new(:name => 'invalid /// name')
    network.should_not be_valid
    network.should have(1).errors_on(:name)
  end

  it "should have many categories" do
    Network.new.categories.should == []
  end
end
