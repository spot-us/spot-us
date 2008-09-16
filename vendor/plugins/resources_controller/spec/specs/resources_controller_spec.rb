require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "ResourcesController (in general)" do
  
  before do
    @controller = Class.new(ApplicationController)
    @controller.resources_controller_for :forums
  end
  
  it "nested_in :foo, :polymorphic => true, :class => User should raise argument error (no options or block with polymorphic)" do
    lambda { @controller.nested_in :foo, :polymorphic => true, :class => User }.should raise_error(ArgumentError)
  end
  
  it "resources_controller_for :forums, :in => [:user, '*', '*', :comment] should raise argument error (no multiple wildcards in a row)" do
    lambda { @controller.resources_controller_for :forums, :in => [:user, '*', '*', :comment] }.should raise_error(ArgumentError)
  end
  
  
end

describe "ResourcesController#enclosing_resource_name" do
  before do
    @controller = ForumsController.new
  end

  it "should be the class name underscored" do
    @controller.instance_variable_set('@enclosing_resources', [mock_model(User)])
    @controller.enclosing_resource_name.should == 'user'
  end
end

describe "A controller's resource_service" do
  
  before do
    @controller = ForumsController.new
  end
    
  it 'may be explicitly set with #resource_service=' do
    @controller.resource_service = 'foo'
    @controller.resource_service.should == 'foo'
  end
end