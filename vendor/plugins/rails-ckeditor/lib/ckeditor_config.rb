require 'yaml'
require 'fileutils'

module Ckeditor

	class Config
		cattr_accessor :filepath
  	@@filepath = File.join(RAILS_ROOT, "config/ckeditor.yml")
    
  	@@available_settings = (File.exists?(@@filepath) ? YAML::load(File.open(@@filepath))[RAILS_ENV] : nil)
  	
  	class << self
  	
			def [](name)
				return if @@available_settings.nil?
				@@available_settings[name.to_s]
			end
		
			def method_missing(method, *args)
				method_name = method.to_s
				return self[method_name].to_s if !@@available_settings.nil? && @@available_settings.keys.include?(method_name)
				super
			end
			
			def exists?
				File.exists?(@@filepath)
			end
			
			def create_yml
        unless File.exists?(@@filepath)
#          asset_yml = Hash.new
#          
#          asset_yml[RAILS_ENV] = {}
#          asset_yml[RAILS_ENV]['public_path'] = "#{RAILS_ROOT}/public/uploads"
#          asset_yml[RAILS_ENV]['public_uri'] = '/uploads'
#          
#          asset_yml[RAILS_ENV]['file_manager_uri'] = '/ckeditor/files'
#          asset_yml[RAILS_ENV]['file_manager_upload_uri'] = '/ckeditor/create?kind=file'
#          asset_yml[RAILS_ENV]['file_manager_image_uri'] = '/ckeditor/images'
#          asset_yml[RAILS_ENV]['file_manager_image_upload_uri'] = '/ckeditor/create?kind=image'
#          
#          asset_yml[RAILS_ENV]['swf_file_post_name'] = 'data'
#          asset_yml[RAILS_ENV]['swf_image_file_size_limit'] = "5 MB"
#          asset_yml[RAILS_ENV]['swf_image_file_types'] = "*.jpg;*.jpeg;*.png;*.gif"
#          asset_yml[RAILS_ENV]['swf_image_file_upload_limit'] = 10
#          asset_yml[RAILS_ENV]['swf_image_file_types_description'] = "Images"
#          
#          asset_yml[RAILS_ENV]['swf_file_size_limit'] = "10 MB"
#          asset_yml[RAILS_ENV]['swf_file_types'] = "*.doc;*.wpd;*.pdf;*.swf;*.xls"
#          asset_yml[RAILS_ENV]['swf_file_file_upload_limit'] = 5
#          asset_yml[RAILS_ENV]['swf_types_description'] = "Files" 
#          
#          File.open(@@filepath, "w") do |out|
#            YAML.dump(asset_yml, out)
#          end

          ck_config = File.join(RAILS_ROOT, 'vendor/plugins/rails-ckeditor/', 'ckeditor.yml.tpl')
          FileUtils.cp ck_config, @@filepath unless File.exist?(@@filepath)
          
          log "#{@@filepath} example file created!"
          log "Please modify your settings"
        else
          log "config/#{@@filepath} already exists. Aborting task..."
        end
      end
			
			def log(message)
        puts message
      end
		end
	end
end
