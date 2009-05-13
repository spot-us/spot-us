$:.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
begin
  gem 'cucumber', '0.1.16'
  require 'cucumber/rake/task'
rescue Gem::LoadError, MissingSourceFile
end

desc "Run all features" 
task :features => 'db:test:prepare'
task :features => "features:all" 

namespace :features do
  Cucumber::Rake::Task.new(:all) do |t|
    t.cucumber_opts = "--format pretty" 
  end

  Cucumber::Rake::Task.new(:rcov) do |t|    
    t.rcov = true
    t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/}
    t.rcov_opts << %[-o "public/features_rcov"]
  end
end
task :default => :features
