# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com

require "eycap/recipes"

# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The :deploy_to variable must be the root of the application.

set :keep_releases,       5
set :application,         "spotus"
set :user,                "spotus"
set :deploy_to,           "/data/#{application}"
set :monit_group,         "spotus"
set :runner,							"spotus"


set :repository,          "git://github.com/spot-us/spot-us.git"
set :scm_username,       ""
set :scm_password,       ""
set :scm,                 :git

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }



ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/tossup_id_rsa"]


set :production_database, "spotus_production"
set :production_dbhost,   "mysql50-10-master"


set :staging_database, "spotus_staging"
set :staging_dbhost,   "mysql50-staging-1"









set :dbuser,        "spotus_db"
set :dbpass,        "eA2KbxR3"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false


# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

  
  
task :production do
  
  role :web, "74.201.152.100:8195" # spotus [mongrel] [mysql50-10-master,mysql50-staging-1]
  role :app, "74.201.152.100:8195", :mongrel => true
  role :db , "74.201.152.100:8195", :primary => true
  
  
  role :app, "74.201.152.100:8196", :no_release => true, :no_symlink => true, :mongrel => true
  
  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

  
  
task :staging do
  
  role :web, "74.201.152.100:8197" # spotus [mongrel] [mysql50-10-master,mysql50-staging-1]
  role :app, "74.201.152.100:8197", :mongrel => true
  role :db , "74.201.152.100:8197", :primary => true
  
  
  set :rails_env, "staging"
  set :environment_database, defer { staging_database }
  set :environment_dbhost, defer { staging_dbhost }
end

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


# =============================================================================
# Any custom after tasks can go here.
# after "deploy:symlink_configs", "spotus_custom"
# task :spotus_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#   CMD
# end
# =============================================================================

# Do not change below unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

