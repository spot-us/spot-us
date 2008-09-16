# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

def timestamp(label)
 puts "*** #{label} @ #{DateTime.now.to_formatted_s :db} ***"
end

task :show_success do
 timestamp "SUCCESSFUL BUILD"
end

task :show_start => :environment do
 timestamp "BUILD"
end