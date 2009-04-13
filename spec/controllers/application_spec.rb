require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe "#current_network" do
    before do
      controller.stubs(:current_subdomain).returns('sfbay')
      @network = Factory(:network, :name => 'sfbay')
      Network.stub!(:find_by_name).and_return(@network)
    end

    it "should ask for the current subdomain" do
      controller.expects(:current_subdomain).returns('sfbay')
      controller.current_network
    end

    it "should load the network for the current domain" do
      Network.should_receive(:find_by_name).with('sfbay').and_return(@network)
      controller.current_network.should == @network
    end

    it "should lower case the network name" do
      controller.stubs(:current_subdomain).returns('SFBAY')
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
