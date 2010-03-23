run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
run "ln -nfs #{shared_path}/config/s3.yml #{release_path}/config/s3.yml"
run "ln -nfs #{shared_path}/config/facebooker.yml #{release_path}/config/facebooker.yml"
#run "sudo /etc/init.d/memcached restart"


