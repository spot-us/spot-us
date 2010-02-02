# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def facebox_login_link_to(*args, &block)
    return link_to(*args, &block) if current_user
    url = url_for(args.second)
    options = args.third || {}
    options.merge!({:class => 'authbox', :return_to => url})
    link_to args.first, new_session_path(:return_to => url), options
  end
  
  def get_network_name?
    " inside #{@current_network.nil? ? "All Networks" : @current_network.display_name}"
  end

  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end

  def current_balance
    return 0 if current_user.donations.unpaid.blank?
    current_user.current_balance
  end

  def topic_check_boxes(resource, model = nil)
    render :partial => "topics/topic", :collection => Topic.all, :locals => {:resource => resource, :model => model}
  end

  def show_topics(resource)
    render :inline => resource.topics.map(&:name).join(', ')
  end
  
  def strip_html(text)
    text.gsub(/<\/?[^>]*>/, "")
  end

  def truncate_words(text, length = 30, end_string = '&hellip; ')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def header_display_message
    returning "" do |text|
      if (current_user.credits? && current_balance == 0)
        text << "You have #{number_to_currency(current_user.total_credits)} in credits. "
        text << link_to("Purchase &raquo;", edit_myspot_donations_amounts_path)
      end
      if (current_user.credits? && current_balance > 0)
        text << "You have #{number_to_currency(current_user.remaining_credits)} in credits to use toward your donations. "
        text << link_to("Apply Them &raquo;", edit_myspot_donations_amounts_path)
      end
      if (!current_user.credits? && current_balance > 0)
        text << "You need "
        text << link_to(number_to_currency(current_balance), edit_myspot_donations_amounts_path, :id => "current_balance")
        text << " to fund your donations. "
        text << link_to("Purchase &raquo;", edit_myspot_donations_amounts_path)
      end
    end
  end

  def networks_for_select
    output = []
    output << ['Select A Network', '']
    output += Network.all.map{|n| [n.display_name, n.id]}
    output
  end

  def categories_for_select(object)
    return ['Sub-network', ''] unless object.network
    output = []
    output << ['Sub-network', '']
    output += object.network.categories.map{|c| [c.name, c.id]}
    output
  end

  def current_network_id
    @current_network.id if @current_network
  end

  def available_pitches_for(tip)
    current_user.pitches.select{|p| !tip.affiliations.map(&:pitch).include?(p) }.map{|p| [p.headline, p.id]}
  end

  def fact_checkers_for(pitch)
    output = ""
    applicants = pitch.contributor_applicants.map{|u| [u.full_name, u.id]}
    applicants = [['No applicants', '']] if applicants.empty?
    output += content_tag('optgroup', options_for_select(applicants), :label => 'Pitch Applicants')
    output += content_tag('optgroup', options_for_select(User.fact_checkers.map{|u| [u.full_name, u.id]}), :label => 'General Interest')
    output += content_tag('optgroup', options_for_select(User.all.map{|u| [u.full_name, u.id]}), :label => 'All Users')
    output
  end
  
  # inserts 'active' css class if true
  def check_if_tab(tab, selected_tab)
      " active" if tab == selected_tab
  end
  
  def due_date_in_words(due_date)
    if due_date > Time.now
      '<span class="deep-green">due in ' + time_ago_in_words(due_date) + "</span>"
    else
      '<span class="deep-red">' + time_ago_in_words(due_date)  + " overdue</span>"
    end
  end
  
  def short_date(dt)
      # tn = Time.now
      # if dt.day < tn.day or dt.month < tn.month or dt.year < tn.year #diff > 60  * 60 * (24 / 1.02)
           dt.strftime("%m.%d.%y")
      # else
      #    dt.strftime("%l:%M %p").downcase
      # end
  end
  
  def medium_date(dt)
    dt.strftime("%B %d, %Y")
  end

end
