# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'factory_girl'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def table_has_columns(clazz, type, *column_names)
  column_names.each do |column_name|
    column = clazz.columns.select {|c| c.name == column_name}.first
    it "has a string named #{column_name}" do
      column.should_not be_nil
      column.type.should == type.to_sym
    end
  end
end

def route_matches(path, method, params)
  it "maps #{params.inspect} to #{path.inspect}" do
    route_for(params).should == path
  end

  it "generates params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, path).should == params
  end
end

