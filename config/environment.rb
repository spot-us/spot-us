RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require 'yaml'

config_file_path = File.join(RAILS_ROOT, *%w(config settings.yml))
if File.exist?(config_file_path)
  config = YAML.load_file(config_file_path)
  APP_CONFIG = config.has_key?(RAILS_ENV) ? config[RAILS_ENV] : {}
else
  puts "WARNING: configuration file #{config_file_path} not found." 
  APP_CONFIG = {}
end

DEFAULT_HOST = APP_CONFIG[:default_host] || "localhost:3000"

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "fastercsv"
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem "rubyist-aasm", :lib => "aasm", :source => 'http://gems.github.com'
  
  config.time_zone = 'UTC'
  
  DEFAULT_SECRET = "552e024ba5bbf493d1ae37aacb875359804da2f1002fa908f304c7b0746ef9ab67875b69e66361eb9484fc0308cabdced715f7e97f02395874934d401a07d3e0"
  secret = APP_CONFIG[:action_controller][:session][:secret] rescue DEFAULT_SECRET
  
  config.action_controller.session = { :session_key => '_spotus_session', :secret => secret }
end

require 'lib/dollars.rb'
