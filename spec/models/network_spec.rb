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

  describe "with_pitches" do
    it "should return an array of Networks" do
      Network.with_pitches.all?{|n| n.kind_of?(Network) }.should be_true
    end
    it "should not contain duplicates" do
      Network.with_pitches.uniq.should == Network.with_pitches
    end
    it "should only contain networks with pitches" do
      network1 = Factory(:network)
      pitch = Factory(:pitch, :network => network1)
      network2 = Factory(:network)
      Network.with_pitches.all?{|n| n.pitches.count > 0 }.should be_true
    end
  end
end
