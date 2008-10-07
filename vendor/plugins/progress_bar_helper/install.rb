# Workaround a problem with script/plugin and http-based repos.
# See http://dev.rubyonrails.org/ticket/8189
Dir.chdir(Dir.getwd.sub(/vendor.*/, '')) do

##
## Copy over asset files (javascript/css/images) from the plugin directory to public/
##

def copy_files(source_path, destination_path, directory)
  source, destination = File.join(directory, source_path), File.join(RAILS_ROOT, destination_path)
  FileUtils.mkdir(destination) unless File.exist?(destination)
  FileUtils.cp_r(Dir.glob(source+'/*.*'), destination)
end

directory = File.dirname(__FILE__)

copy_files("/public", "/public", directory)

[ :javascripts, :images].each do |asset_type|
  path = "/public/#{asset_type}/progress_bar"
  copy_files(path, path, directory)
  
  source = "/public/#{asset_type}/"
  destination = "/public/#{asset_type}/progress_bar"
  copy_files(source, destination, directory)
end

end
