# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end

  def current_balance
    return 0 if current_user.donations.unpaid.blank?
    current_user.donations.unpaid.map(&:amount_in_cents).sum
  end

  def topic_check_boxes(resource, model = nil)
    render :partial => "topics/topic", :collection => Topic.all, :locals => {:resource => resource, :model => model}
  end

  def show_topics(resource)
    render :inline => resource.topics.map(&:name).join(', ')
  end

  def truncate_words(text, length = 30, end_string = '… ')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def header_display_message
    returning "" do |text|
      if (current_user.credits? && current_balance == 0)
        text << "You have #{number_to_currency(current_user.total_credits_in_dollars)} in credit. "
      end
      if (current_user.credits? && current_balance > 0)
        text << "You have #{number_to_currency(current_user.total_credits_in_dollars)} in credits to use toward your donations. "
        text << link_to("Apply Them &raquo;", edit_myspot_donations_amounts_path)
      end
      if (!current_user.credits? && current_balance > 0)
        text << "You need "
        text << link_to(number_to_currency(current_balance.to_dollars), edit_myspot_donations_amounts_path, :id => "current_balance")
        text << " to fund your donations. "
        text << link_to("Purchase &raquo;", edit_myspot_donations_amounts_path)
      end
    end
  end
end
