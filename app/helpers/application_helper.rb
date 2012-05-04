# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def facebox_login_link_to(*args, &block)
    return link_to(*args, &block) if current_user
    url = url_for(args.second)
    cookies[:return_to] = args.third[:return_to] if args.third && args.third[:return_to]
    options = args.third || {}
    options.merge!({:return_to => url, :rel=>"nofollow"})
    link_to args.first, new_session_path(:return_to => url), options
  end
  
  def show_cca?(show_cca)
    return true
    return !show_cca
  end
  
  def get_network_name?(pre_text=" inside ")
    "#{pre_text}#{@current_network.nil? ? "All Networks" : @current_network.display_name}"
  end

  def transform_embed_code(embed_code, width, height)
    embed_code = embed_code.gsub(/width="([0-9]+)"/, "width='#{width}'")
    embed_code = embed_code.gsub(/width:"([0-9]+)"/, "width:'#{width}'")
    embed_code = embed_code.gsub(/height="([0-9]+)"/, "height='#{height}'")
    embed_code = embed_code.gsub(/height:"([0-9]+)"/, "height:'#{height}'")
    embed_code
  end
  
  def parse_xml_created_at(xml, posts)
    if posts
      unless posts.empty?
        xml.pubDate posts.first.created_at.to_s(:rfc822) 
        xml.lastBuildDate posts.first.created_at.to_s(:rfc822)
      else
        xml.pubDate Time.now.to_s(:rfc822) 
        xml.lastBuildDate Time.now.to_s(:rfc822)
      end
    end
  end
  
  def apply_fragment(key, options = {}, &block)    
    options[:skip] ? block.call : cache(reduce_cache_key(key), options, &block)
  rescue Memcached::Error
    block.call
  end
  
  def reduce_cache_key(key)
    final_key = ActiveSupport::Cache.expand_cache_key(key)
    final_key.gsub!(" ","")
    Digest::SHA1.hexdigest(final_key)
  end
  
  def body_class
    controller.controller_path.underscore.gsub('/', '_')
  end

  def current_balance
    #return 0 if current_user.donations.unpaid.blank? && current_user.credit_pitches.unpaid.blank?
    current_user.current_balance
  end

  def get_comments_url(commentable)
    if commentable.type.to_s=='Pitch'
      return "#{pitch_url(commentable)}/comments"
    elsif commentable.type.to_s=='Story'
      return "#{story_url(commentable)}/comments"
    elsif commentable.type.to_s=='Tip'
      return "#{tip_url(commentable)}/comments"
    end
  end
  
  def get_unsubscribe_link_text(subscriber)
    url  = "Go to: #{root_url}"
    url += subscriber ? "subscription/cancel/#{@subscriber.invite_token}" : "myspot/settings/edit"
    url
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
    words = text.split(' ')
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def header_display_message
    returning "" do |text|
      if (current_user.total_credits<=0 && current_balance == 0)
        text << "You have no credits or unpaid donations. "
        text << link_to("Purchase &raquo;", edit_myspot_donations_amounts_path)
      end
      if (current_user.total_credits>0 && current_balance > 0)
        text << "You have #{number_to_currency(current_user.remaining_credits)} in credits to use toward your donations. "
        text << link_to("Apply Them &raquo;", edit_myspot_donations_amounts_path)
      end
      if (current_user.total_credits>0 && current_balance == 0)
        text << "You have #{number_to_currency(current_user.remaining_credits)} in credits to use. "
        text << link_to("Apply Them &raquo;", edit_myspot_donations_amounts_path)
      end
      if (current_user.total_credits<=0 && current_balance > 0)
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
      '<span class="grey">due in ' + time_ago_in_words(due_date) + "</span>"
    else
      '<span class="grey">' + time_ago_in_words(due_date)  + " overdue</span>"
    end
  end

  def pitch_date(dt)
	  dt.strftime("%m/%d/%y")
  end
  
  def post_date(dt)
	  "#{dt.month}/#{dt.day}/#{dt.year.to_s[2..3]}"
  end
  
  def report_an_error_date(dt)
	  dt.strftime("%Y-%b-%d")
  end
  
  def short_date(dt)
    dt.strftime("%m/%d/%y")
  end
  
  # getting email field for mailer from role for email accounts
  def get_email(role, only_email=false)
    if only_email
      return APP_CONFIG[:action_mailer][:accounts][role][:email] if role
      return APP_CONFIG[:action_mailer][:accounts][:info][:email]
    else
      return "'#{APP_CONFIG[:action_mailer][:accounts][role][:name]}' <#{APP_CONFIG[:action_mailer][:accounts][role][:email]}>" if role
      return "'#{APP_CONFIG[:action_mailer][:accounts][:info][:name]}' <#{APP_CONFIG[:action_mailer][:accounts][:info][:email]}>"
    end
  end
  
  # getting the name from role for email accounts
  def get_name(role)
    return APP_CONFIG[:action_mailer][:accounts][role][:name] if role
    APP_CONFIG[:action_mailer][:accounts][:info][:name]
  end
  
  def medium_date(dt)
    dt.strftime("%B %d, %Y")
  end
  
  def is_admin?
    current_user && current_user.admin?
  end
  
  # get the stylesheets...
  def get_stylesheets(is_admin=false)
    stylesheets = ['base', 'main', 'facebox']
    stylesheets.concat(['new_style','widget']) if params[:controller]!='homes' && params[:controller]!='pitches' && params[:controller]!='news_items' && params[:controller]!='posts' && params[:controller]!='session' && params[:controller]!='pages' && params[:controller]!='stories'
    stylesheets << 'admin' if is_admin
    stylesheet_link_tag stylesheets, :media => "all", :cache => stylesheet_name?(stylesheets)
  end
  
  def stylesheet_name?(stylesheets)
    names = ['global']
    names << 'styles' if stylesheets.detect { |s| s =~ /(?:new_style)/i }
    names << "admin" if stylesheets.detect { |s| s =~ /(?:admin)/i }  
    "cache/#{names.join('_')}"
  end
  
  def get_button(button_text, options={})
    options[:class] = "submitButton"
    submit_tag button_text, options
  end 
  
  def excerpt?(text, strip_length=50)
    text = strip_html(text)
    text.length>strip_length ? text[0..strip_length].gsub(/\w+$/, '')+"..." : text
  end
  
  def format_credits(credits)
    number_with_delimiter(number_with_precision(credits, :precision => 2))
  end

end
