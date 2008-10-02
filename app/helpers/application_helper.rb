# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end

  def topic_check_boxes(resource)
    render :partial => Topic.all, :locals => {:resource => resource}
  end
  
  def show_topics(resource)
    render :partial => "topics/show_topic", :collection => resource.topics
  end

end
