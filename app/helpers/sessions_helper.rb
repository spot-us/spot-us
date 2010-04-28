module SessionsHelper
  def session_field_class_name
    if login_failed?
      'fieldWithErrors'
    else
      ''
    end
  end

  def login_failed?
    params[:controller] == 'sessions' && params[:action] == 'create'
  end
  
  def fb_login_link
    link_to image_tag("/images/new_design/fb_icon.png", :style => "vertical-align:text-bottom") + ' connect', "/auth/facebook", :id => "fb_login_link"
  end
  
  def fb_logged_in
    image_tag("/images/new_design/fb_icon.png", :style => "vertical-align:text-bottom") + ' connected'
  end
end
