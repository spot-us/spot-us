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
  config.gem "haml"
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem "rubyist-aasm", :lib => "aasm", :source => 'http://gems.github.com'
  
  config.time_zone = 'UTC'
  
  config.action_controller.session = {
    :session_key => '_spotus_session',
    :secret      => APP_CONFIG[:action_controller][:session][:secret]
  }
end

require 'lib/dollars.rb'
