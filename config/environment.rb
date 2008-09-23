RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require 'yaml'

config_file_path = File.join(RAILS_ROOT, *%w(public system config.yml))
if File.exist?(config_file_path)
  config = YAML.load_file(config_file_path)
  APP_CONFIG = config.has_key?(RAILS_ENV) ? config[RAILS_ENV] : {}
else
  puts "WARNING: configuration file #{config_file_path} not found." 
  APP_CONFIG = {}
end

Rails::Initializer.run do |config|
  config.gem "haml"#, :version => 2.0.3
  config.gem 'thoughtbot-factory_girl',
             :lib => 'factory_girl',
             :source => 'http://gems.github.com'
  
  config.time_zone = 'UTC'
  
  config.action_controller.session = {
    :session_key => '_spotus_session',
    :secret      => '5364db1b81e0c120704c572a45f1c6929d10c54ea5b4069680f396e898d8af69920ad7ec1524c5a8f32340624c61f4232204d299b484108bbcdefed1a26f7e7a'
  }
end

