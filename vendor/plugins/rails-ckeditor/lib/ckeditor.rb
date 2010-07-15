# Ckeditor
module Ckeditor
  PLUGIN_NAME = 'rails-ckeditor'
  PLUGIN_PATH = File.join(RAILS_ROOT, "vendor/plugins", PLUGIN_NAME)
  
  PLUGIN_PUBLIC_PATH = Ckeditor::Config.exists? ? Ckeditor::Config['public_path'] : "#{RAILS_ROOT}/public/uploads"
  PLUGIN_PUBLIC_URI  = Ckeditor::Config.exists? ? Ckeditor::Config['public_uri'] : "/uploads"
  
  PLUGIN_CONTROLLER_PATH = File.join(PLUGIN_PATH, "/app/controllers")
  PLUGIN_VIEWS_PATH      = File.join(PLUGIN_PATH, "/app/views")
  PLUGIN_HELPER_PATH     = File.join(PLUGIN_PATH, "/app/helpers")
  
  PLUGIN_FILE_MANAGER_URI        = Ckeditor::Config.exists? ? Ckeditor::Config['file_manager_uri'] : ""
  PLUGIN_FILE_MANAGER_UPLOAD_URI = Ckeditor::Config.exists? ? Ckeditor::Config['file_manager_upload_uri'] : ""
  PLUGIN_FILE_MANAGER_IMAGE_URI  = Ckeditor::Config.exists? ? Ckeditor::Config['file_manager_image_uri'] : ""
  PLUGIN_FILE_MANAGER_IMAGE_UPLOAD_URI = Ckeditor::Config.exists? ? Ckeditor::Config['file_manager_image_upload_uri'] : ""

  module Helper
    include ActionView::Helpers
    
    def ckeditor_textarea(object, field, options = {})
      options.symbolize_keys!
      
      var = options.delete(:object) if options.key?(:object)
      var ||= @template.instance_variable_get("@#{object}")
      
      if var
        value = var.send(field.to_sym)
        value = value.nil? ? "" : value
      else
        value = ""
        klass = "#{object}".camelcase.constantize
        instance_variable_set("@#{object}", eval("#{klass}.new()"))
      end
      id = ckeditor_element_id(object, field)

      cols = options[:cols].nil? ? "cols='70'" : "cols='"+options[:cols]+"'"
      rows = options[:rows].nil? ? "rows='20'" : "rows='"+options[:rows]+"'"

      width = options[:width].nil? ? '100%' : options[:width]
      height = options[:height].nil? ? '100%' : options[:height]

      classy = options[:class].nil? ? '' : "class='#{options[:class]}'"
      
      ckeditor_options = {}
      
      ckeditor_options[:toolbar] = options[:toolbar] unless options[:toolbar].nil?
      ckeditor_options[:skin] = options[:skin] unless options[:skin].nil?
      ckeditor_options[:language] = options[:language] unless options[:language].nil?
      ckeditor_options[:width] = options[:width] unless options[:width].nil?
      ckeditor_options[:height] = options[:height] unless options[:height].nil?
      
      ckeditor_options[:swf_params] = options[:swf_params] unless options[:swf_params].nil?
      
      ckeditor_options[:filebrowserBrowseUrl] = PLUGIN_FILE_MANAGER_URI
      ckeditor_options[:filebrowserUploadUrl] = PLUGIN_FILE_MANAGER_UPLOAD_URI
      
      ckeditor_options[:filebrowserImageBrowseUrl] = PLUGIN_FILE_MANAGER_IMAGE_URI
      ckeditor_options[:filebrowserImageUploadUrl] = PLUGIN_FILE_MANAGER_IMAGE_UPLOAD_URI

      if options[:ajax]
        inputs = "<input type='hidden' id='#{id}_hidden' name='#{object}[#{field}]'>\n" <<
                 "<textarea id='#{id}' #{cols} #{rows} name='#{id}'>#{value}</textarea>\n"
      else
        inputs = "<textarea id='#{id}' style='width:#{width};height:#{height}' #{cols} #{rows} #{classy} name='#{object}[#{field}]'>#{h value}</textarea>\n"
      end
      
      return inputs << javascript_tag("CKEDITOR.replace('#{object}[#{field}]', { 
          #{ckeditor_applay_options(ckeditor_options)}
        });\n")
    end

    def ckeditor_form_remote_tag(options = {})
      editors = options[:editors]
      before = ""
      editors.keys.each do |e|
        editors[e].each do |f|
          before += ckeditor_before_js(e, f)
        end
      end
      options[:before] = options[:before].nil? ? before : before + options[:before]
      form_remote_tag(options)
    end

    def ckeditor_remote_form_for(object_name, *args, &proc)
      options = args.last.is_a?(Hash) ? args.pop : {}
      concat(ckeditor_form_remote_tag(options), proc.binding)
      fields_for(object_name, *(args << options), &proc)
      concat('</form>', proc.binding)
    end
    alias_method :ckeditor_form_remote_for, :ckeditor_remote_form_for

    def ckeditor_element_id(object, field)
      #id = eval("@#{object}.id")
      #"#{object}_#{id}_#{field}_editor"
      "#{object}_#{field}_editor"
    end

    def ckeditor_div_id(object, field)
      id = eval("@#{object}.id")
      "div-#{object}-#{id}-#{field}-editor"
    end

    def ckeditor_before_js(object, field)
      id = ckeditor_element_id(object, field)
      "var oEditor = CKEDITOR.instances.#{id}.getData();"
    end
    
    def ckeditor_applay_options(options={})
      str = []
      options.each do |k, v|
        value = case v.class.to_s
          when 'String' then "'#{v}'"
          when 'Hash' then "{ #{ckeditor_applay_options(v)} }"
          else v
        end
        str << "#{k}: #{value}"
      end
      
      str.join(',')
    end
  end
end

include ActionView
module ActionView::Helpers::AssetTagHelper
  alias_method :rails_javascript_include_tag, :javascript_include_tag

  #  <%= javascript_include_tag :defaults, :ckeditor %>
  def javascript_include_tag(*sources)
    main_sources, application_source = [], []
    if sources.include?(:ckeditor)
      sources.delete(:ckeditor)
      sources.push('ckeditor/ckeditor')
    end
    unless sources.empty?
      main_sources = rails_javascript_include_tag(*sources).split("\n")
      application_source = main_sources.pop if main_sources.last.include?('application.js')
    end
    [main_sources.join("\n"), application_source].join("\n")
  end
end

module ActionView::Helpers
	class FormBuilder
		include Ckeditor::Helper
		
		def cktext_area(method, options = {})
    	ckeditor_textarea(@object_name, method, objectify_options(options))
    end
	end
end
