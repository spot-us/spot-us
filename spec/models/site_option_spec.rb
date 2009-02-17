require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteOption do

  requires_presence_of SiteOption, :key
  requires_presence_of SiteOption, :value

  it "should have a for class method" do
    SiteOption.should respond_to(:for)
  end

  it "should return a value based on a key" do
    SiteOption.create!(:key => :key, :value => 'value')
    SiteOption.for(:key).should == 'value'
  end
end
