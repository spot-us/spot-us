require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "#current_network" do
    before do
      controller.stub!(:current_subdomain).and_return('sfbay')
      @network = Factory(:network, :name => 'sfbay')
      Network.stub!(:find_by_name).and_return(@network)
    end

    it "should ask for the current subdomain" do
      controller.should_receive(:current_subdomain).and_return('sfbay')
      controller.current_network
    end

    it "should load the network for the current domain" do
      Network.should_receive(:find_by_name).with('sfbay').and_return(@network)
      controller.current_network.should == @network
    end

    it "should lower case the network name" do
      controller.stub!(:current_subdomain).and_return('SFBAY')
      Network.should_receive(:find_by_name).with('sfbay').and_return(@network)
      controller.current_network
    end

    it "should return nil if it can't find one" do
      Network.stub!(:find_by_name).and_return(nil)
      controller.current_network.should == nil
    end

    it "should create a current_network instance variable" do
      controller.current_network
      controller.instance_variable_get(:@current_network).should == @network
    end

    it "should use the instance variable instead of querying the database" do
      controller.instance_variable_set(:@current_network, @network)
      Network.should_receive(:find_by_name).never
      controller.current_network
    end
  end

end
