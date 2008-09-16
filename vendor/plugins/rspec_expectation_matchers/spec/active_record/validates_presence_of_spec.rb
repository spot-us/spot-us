require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Spec::Rails::Matchers::ValidatesPresenceOf, :behavior_type => :model do

  before(:each) do
    @model = mock('Model')
    @model.stub!(:errors).and_return([])
    @attribute_name = :username
    @vpo = Spec::Rails::Matchers::ValidatesPresenceOf.new(@attribute_name)
    @vpo.matches?(@model)
  end

  it 'should state the attribute it is validating in the description' do
    @vpo.description.should == "validate presence of #{@attribute_name.to_s}"
  end

  it 'should properly state the failure message' do
    @vpo.failure_message.should =~ / does not validates presence of :#{@attribute_name} as expected./
  end

  it 'should properly state the negative failure message' do
    @vpo.negative_failure_message.should =~ / appears to validates presence of :#{@attribute_name}./
  end

end
