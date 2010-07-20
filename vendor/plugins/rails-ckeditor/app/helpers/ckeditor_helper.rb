module CkeditorHelper
  def new_attachment_path_with_session_information(kind)
    session_key = ActionController::Base.session_options[:key]
    
    options = {}
    controller = case kind
      when :image then Ckeditor::PLUGIN_FILE_MANAGER_IMAGE_UPLOAD_URI
      when :file  then Ckeditor::PLUGIN_FILE_MANAGER_UPLOAD_URI
      else '/ckeditor/create'
    end
    
    if controller.include?('?')
      arr = controller.split('?')
      options = Rack::Utils.parse_query(arr.last)
      controller = arr.first
    end
    
    options[:controller] = controller
    options[:protocol] = "http://"
    options[session_key] = cookies[session_key]
    options[request_forgery_protection_token] = form_authenticity_token unless request_forgery_protection_token.nil?
    
    url_for(options)
  end
  
  def file_image_tag(filename, path)
    extname = File.extname(filename)
    
    image = case extname.to_s
      when '.swf' then '/javascripts/ckeditor/images/swf.gif'
      when '.pdf' then '/javascripts/ckeditor/images/pdf.gif'
    end
    
    image_tag(image, :alt=>path, :title=>filename, :onerror=>"this.src='/javascripts/ckeditor/images/ckfnothumb.gif'", :class=>'image')
  end
end
