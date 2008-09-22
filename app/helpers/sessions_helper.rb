module SessionsHelper
  def session_field_class_name
    if params[:action] == 'create'
      'fieldWithErrors'
    else
      ''
    end
  end
end
