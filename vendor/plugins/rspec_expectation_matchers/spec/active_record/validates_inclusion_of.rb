require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe Spec::Rails::Matchers::ValidatesInclusionOf, ' - when deriving an invalid value from an range', :behavior_type => :model do

  before(:each) do
    @vio = Spec::Rails::Matchers::ValidatesInclusionOf.new(:some_attribute)
  end

  it 'should create a value outside of a range of floating point numbers' do
    range = (1.1..9.9)
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end

  it 'should create a value outside of a positive..positive range' do
    range = (1..9)
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end

  it 'should create a value outside of a negative..negative range' do
    range = (-9..-1)
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end

  it 'should create a value outside of a range in which the range is like a..b in which a > b and both a and b are positive' do
    a = 9
    b = 1
    a.should > b
    range = (a..b)
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end

  it 'should create a value outside of a range in which the range is like a..b in which a > b and both a and b are negative' do
    a = -1
    b = -9
    a.should > b
    range = (a..b)
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end

  it 'should create a value outside of a range in which the range is like (-a)..a for a positive' do
    a = 9
    range = (-a)..a
    range.should_not be_include(@vio.derive_invalid_value_from_enumerable(range))
  end
end

describe Spec::Rails::Matchers::ValidatesInclusionOf, ' - when deriving an invalid value from an enumerable of numeric values', :behavior_type => :model do

  before(:each) do
    @vio = Spec::Rails::Matchers::ValidatesInclusionOf.new(:some_attribute)
  end

  it 'should create a value not within an array of positive numbers' do
    array = [1, 2, 3]
    array.should_not be_include(@vio.derive_invalid_value_from_enumerable(array))
  end

  it 'should create a value not within an array of negative numbers' do
    array = [-1, -2, -3]
    array.should_not be_include(@vio.derive_invalid_value_from_enumerable(array))
  end

  it 'should create a value not within an array of positive and negative numbers' do
    array = [-1, 0, 1]
    array.should_not be_include(@vio.derive_invalid_value_from_enumerable(array))
  end

  it 'should create a numeric result if a value in the array is a string' do
    array = [1,'ni',3]
    array.should_not be_include(@vio.derive_invalid_value_from_enumerable(array))
  end
end

describe Spec::Rails::Matchers::ValidatesInclusionOf, ' - when deriving an invalid value from an enumerable of strings', :behavior_type => :model do

  before(:each) do
    @vio = Spec::Rails::Matchers::ValidatesInclusionOf.new(:some_attribute)
  end

  it 'should create a string value not within an array of strings' do
    array = ['cat', 'dog']
    array.should_not be_include(@vio.derive_invalid_value_from_enumerable(array))
  end
end
