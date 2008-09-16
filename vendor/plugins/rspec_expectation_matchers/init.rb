if RAILS_ENV == 'test'
  require File.join(File.dirname(__FILE__), 'lib/action_controller')
  require File.join(File.dirname(__FILE__), 'lib/active_record')
end