# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end
  
  def current_balance
    return 0 if current_user.donations.unpaid.blank?
    current_user.donations.unpaid.map(&:amount_in_cents).sum.to_dollars
  end

  def topic_check_boxes(resource, model = nil)
    render :partial => "topics/topic", :collection => Topic.all, :locals => {:resource => resource, :model => model}
  end
  
  def show_topics(resource)
    render :inline => resource.topics.map(&:name).join(', ')
  end

end
