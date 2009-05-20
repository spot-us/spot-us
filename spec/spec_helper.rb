# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'factory_girl'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.with_options(:behaviour_type => :helpers) do |config|
    config.include Haml::Helpers
    config.include ActionView::Helpers
    config.prepend_before :all do
       init_haml_helpers
    end
  end

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
  config.include AuthenticatedTestHelper
end

def table_has_columns(clazz, type, *column_names)
  column_names.each do |column_name|
    column = clazz.columns.select {|c| c.name == column_name.to_s}.first
    it "has a #{type} named #{column_name}" do
      column.should_not be_nil
      column.type.should == type.to_sym
    end
  end
end

def route_matches(path, method, params)
  it "maps #{params.inspect} to #{path.inspect}" do
    route_for(params).should == {:path => path, :method => method}
  end

  it "generates params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, path).should == params
  end
end

def requires_login_for(method, action)
  describe "in the name of security" do
    before(:each) { send(method, action) }
    it_denies_access
  end
end

def it_denies_access(opts = {})
  flash_msg = opts[:flash] || /logged in/i
  redirect_path = opts[:redirect] || "new_session_path"

  it "sets the flash to #{flash_msg.inspect}" do
    flash[:error].should match(flash_msg)
  end

  it "redirects to #{redirect_path}" do
    response.should redirect_to(eval(redirect_path))
  end
end

def requires_presence_of(clazz, field)
  it "requires #{field}" do
    Network.create!(:name => 'sfbay', :display_name => 'Bay Area')
    record = Factory.build(clazz.to_s.underscore.to_sym, field.to_sym => nil)
    record.should_not be_valid
    record.errors.on(field.to_sym).should_not be_nil
  end
end

def requires_presence_of_field_on_purchase(clazz, field)
  it "requires #{field}" do
    record = Factory.build(clazz.to_s.underscore.to_sym, field.to_sym => nil)
    record.stub!(:credit_covers_total?).and_return(false)
    record.should_not be_valid
    record.errors.on(field.to_sym).should_not be_nil
  end
end

def has_dollar_field(clazz, field_name)
  field_name = field_name.to_sym
  class_sym = clazz.to_s.underscore.to_sym
  cents_field = :"#{field_name}_in_cents"

  it "returns #{field_name} on ##{field_name}" do
    rec = Factory(class_sym)
    rec[cents_field] = "1234"
    rec.save!
    rec.reload
    rec.send(field_name).should == "12.34"
  end

  it "can set #{field_name} via ##{field_name}=" do
    rec = Factory(class_sym, field_name => "12.34")
    rec.reload
    rec.send(cents_field).should == 1234
  end
end

class Object
  def stub_chain(*methods)
    while methods.length > 1 do
      stub!(methods.shift).and_return(self)
    end
    stub!(methods.shift)
  end
end
