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
end
