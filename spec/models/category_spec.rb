require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do

  it "should require a name" do
    category = Category.new
    category.should_not be_valid
    category.should have(1).errors_on(:name)
  end

  it "should require a unique name" do
    Category.create!(:name => 'name')
    category = Category.new(:name => 'name')
    category.should_not be_valid
    category.should have(1).errors_on(:name)
  end

  it "should belong to a network" do
    Category.new.should respond_to(:network)
  end

end
