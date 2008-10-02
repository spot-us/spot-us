namespace :db do
  desc "Loads seed data for the current environment."
  task :populate => :environment do
    run_fixtures "."
    run_fixtures "shared"
    run_fixtures RAILS_ENV
  end
end

def run_fixtures(relative_path)
  Dir[File.join(RAILS_ROOT, 'db', 'fixtures', relative_path, '*.rb')].sort.each do |fixture|
    puts "Running #{fixture}..."
    load fixture
  end
end
