##
## Delete public asset files
##

require 'fileutils'

directory = File.dirname(__FILE__)

[ :javascripts, :images].each do |asset_type|
  path = File.join(directory, "../../../public/#{asset_type}/progress_bar_helper")
  FileUtils.rm_r(path)
end
