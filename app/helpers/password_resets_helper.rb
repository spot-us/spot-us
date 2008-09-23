module PasswordResetsHelper
  def password_reset_field_class_name
    if params[:email].blank?
      ''
    else
      'fieldWithErrors'
    end
  end
end
