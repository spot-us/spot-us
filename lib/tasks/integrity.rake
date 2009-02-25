spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? :has_database : :no_database
task :no_database do
  $stderr.puts "No database.yml found. Perhaps you should rename the example?"
end

task :has_database do
  $stderr.puts "Running Pending Migrations..."
end
namespace :integrity do
  
  desc 'Initial setup, run this once'
  task :setup => spec_prereq do
    Rake::Task["gems:install"].invoke
    Rake::Task["db:create:all"].invoke
  end
  
  desc 'Integrity build target, runs migrations and specs'
  task :build => spec_prereq do
    Rake::Task["gems:install"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:test:prepare"].invoke
    Rake::Task["spec"].invoke
    Rake::Task["features"].invoke
  end
end
