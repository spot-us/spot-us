require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))

module AddColumnAfter
  class AdapterNotSupported < StandardError; end;
end

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
if configuration = config[ENV['DB'] || 'mysql']
  if configuration[:adapter] != 'mysql'
    raise AddColumnAfter::AdapterNotSupported, "The adapter specified by the environment, #{config[ENV['DB']][:adapter]}, is not supported"
  end
else
  raise ActiveRecord::AdapterNotSpecified, "#{ENV['DB']} database is not configured"
end

ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'mysql'])
