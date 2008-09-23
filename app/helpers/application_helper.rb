# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end

end
