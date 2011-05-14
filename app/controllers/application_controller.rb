class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  filter_parameter_logging :password, :password_confirmation, :credit_card_number
  helper :all # include all helpers, all the time
  
  BOT_FILTER = /(?:Googlebot|Slurp|Apache|msnbot|wget|libwww|nutch|ia_archiver|heretrix|cuil|google|yandex)/i
  
  include AuthenticatedSystem
  include SslRequirement

  include BounceBots

  # cache_sweeper :home_sweeper, :except => [:index, :show]

  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :destroy]
  before_filter :current_network
  before_filter :block_ips
  before_filter :clear_spotus_lite
  before_filter :set_cca
  before_filter :set_default_html_meta_tags
  before_filter :social_notifier
  before_filter :load_classes, :if => Proc.new { Rails.env.development? }
  after_filter  :async_posts
  after_filter :save_clickstream, :if => :save_clickstream?

  map_resource :profile, :singleton => true, :class => "User", :find => :current_user
  
  META_DESCRIPTION = "Spot.Us enables the public to commission journalists to do investigations on important and perhaps overlooked stories. " + 
                  "We are an open source project, to pioneer \"community funded reporting.\""
  META_KEYWORDS = "journalism, reporting, community, local, news, open source, media, donation, creative commons"
  
  before_filter :set_fb_session
  
  after_filter :minify_html, :unless => Proc.new { Rails.env.development? }

  helper_method :fb_session
  def fb_session
    session[:fb_session]
  end
  
  def save_clickstream?
    params[:controller]!='sitemap' && params[:controller]!='comments' && params[:action]!="destroy"#&& !(params[:controller]=~/(?:admin)/i)
  end
  
  def save_clickstream
    
    return if current_user && current_user.admin? 
    
    arg = {}

    user_agent = request ? request.user_agent : nil
    return if user_agent =~ BOT_FILTER

    user_agent = user_agent[0,255] if user_agent && user_agent.size > 256

    arg[:ip] = request.remote_ip if request
    arg[:url] = request.request_uri if request
    arg[:session_id] = session.session_id if session && !session.empty?
    arg[:user_agent] = user_agent
    arg[:user_id] = session[:user_id]
    arg[:referer] = request.env["HTTP_REFERER"]

    if @profile
      arg[:clickstreamable_type] = 'User'
      arg[:clickstreamable_id] = @profile.id
    elsif @post
      arg[:clickstreamable_type] = 'Post'
      arg[:clickstreamable_id] = @post.id
    elsif @story
      arg[:clickstreamable_type] = 'Story'
      arg[:clickstreamable_id] = @story.id
    elsif @pitch
      arg[:clickstreamable_type] = 'Pitch'
      arg[:clickstreamable_id] = @pitch.id
    elsif params[:controller]=='homes'
      arg[:clickstreamable_type] = 'Home'
      arg[:clickstreamable_id] = 0
    elsif params[:controller]=='sessions'
      arg[:clickstreamable_type] = 'Session'
      arg[:clickstreamable_id] = 0
    else
      return 
    end

    Clickstream.create(arg) if arg && !arg.empty?
    
  end
  
  def load_classes
    Pitch
    NewsItem
    Story
    User
    Organization
    Reporter
    Citizen
  end
  
  def display_404
    @page_not_found = true
    render :file => "pages/notfound", :use_full_path => true, :layout => true, :status => 404, :page_not_found=>true
    return
  end
  
  def social_notifier
    if current_user
      if cookies[:social_notifier_shown]
         delete_cookie(:social_notifier) if cookies[:social_notifier]
         delete_cookie(:social_notifier_shown)
      elsif cookies[:social_notifier]
        set_cookie("social_notifier_shown", {:value => "true"})
        case cookies[:social_notifier]
          when "donation"
      			if session[:donation_id]
              @notify_object = Donation.find_by_id(session[:donation_id])  # current_user.donations.last
      				session[:donation_id] = nil
      			end
          when "post"
            @notify_object = current_user.posts.last
        end
      end
    end
  end
	
	def async_posts
	  if current_user && current_user.facebook_user?
      ap = current_user.async_posts.facebook_wall_updates_to_post.first
      if ap && fb_session
        begin
          current_user.post_fb_wall({:message=>ap.message, 
            :description=>ap.description, 
            :link=>ap.link, 
            :picture=>ap.picture, 
            :name=>ap.title})
          ap.status = 1
          ap.save
        rescue
        end
      end
    end
  end
	
  def block_ips
    return head(:bad_request) if ['174.129.157.195','67.202.11.49','72.44.61.86'].include?(request.remote_ip)
    return head(:bad_request) if ['wiki.spot.us','w3.spot.us'].include?(request.domain)
  end
  
  # clear cookie if inside the normal site
  def clear_spotus_lite
    unless ['myspot/donation_amounts','myspot/donations','myspot/purchases','lite'].include?(params[:controller])
      cookies.delete :spotus_lite
    end
  end
  
  def set_cca
    ccas = Cca.live
    @first_cca = nil
    unless current_user
      @first_cca = ccas.first unless ccas.empty?
    else
      ccas.each { |cca| @first_cca = cca unless @first_cca || cca.survey_completed?(current_user) }
    end
    @show_cca = !@first_cca.nil?
	  @cca_link = @first_cca && ccas && ccas.length==1 ? cca_path(@first_cca) : "/cca"
  end
  
  # minify the html
  def minify_html
    response.body.gsub!(/[ \t\v]+/, ' ')
    response.body.gsub!(/\s*[\n\r]+\s*/, "\n")
    response.body.gsub!(/>\s+</, '> <')
    response.body.gsub!(/<\!\-\-([^>\n\r]*?)\-\->/, '')
  end

  def current_network
    subdomain = current_subdomain.downcase if current_subdomain
  	if !APP_CONFIG[:has_networks] && subdomain && subdomain!='la'
  		redirect_to root_url(:subdomain => false) + request.request_uri[1..-1] #request.protocol + request.host_with_port + 
  	end
    @current_network ||= Network.find_by_name(subdomain)
  end
  
  def set_default_html_meta_tags
     @meta_description = META_DESCRIPTION
     @meta_keywords = META_KEYWORDS
  end
  
  def html_meta_tags(meta_description = META_DESCRIPTION, meta_keywords = META_KEYWORDS)
     @meta_description = "Spot.Us Community Report: " + strip_html(meta_description)[0..180] if meta_description and !meta_description.blank?
     @meta_keywords = META_KEYWORDS + ", " + meta_keywords if meta_keywords and !meta_keywords.blank?   
  end
  
  def strip_html(text)
     text.gsub(/<\/?[^>]*>/, "")
  end

  protected
 
  def set_fb_session
    #debugger
    current_user.fb_session ||= session[:fb_session]  if current_user && !session[:fb_session].blank?
  end
  
  def login_cookies
    create_current_login_cookie
    update_balance_cookie
  end

  def create_current_login_cookie
    set_cookie("current_user_full_name", {:value => current_user.full_name})
  end

  def can_create?
    true
  end

  def can_edit?
    true
  end

  def update_balance_cookie
    set_cookie("balance_text",  {:value => render_to_string(:partial => 'shared/balance')})
  end

  def set_social_notifier_cookie(notify_type)
    set_cookie("social_notifier", {:value => notify_type})
  end
  
  def set_cookie(name, options={})
    cookies[name.to_sym] = options.merge(:domain => DEFAULT_HOST)
  end
  
  def delete_cookie(name)
    cookies.delete(name.to_sym, :domain => DEFAULT_HOST)
  end

  def handle_first_donation_for_non_logged_in_user
    if cookies[:news_item_id] && cookies[:donation_amount]
      self.current_user.donations.create(:pitch_id => cookies[:news_item_id], :amount => cookies[:donation_amount])
      cookies[:news_item_id] = nil
      cookies[:donation_amount] = nil
    end
  end

  def handle_first_pledge_for_non_logged_in_user
    if session[:news_item_id] && session[:pledge_amount]
      self.current_user.pledges.create(:tip_id => session[:news_item_id], :amount => session[:pledge_amount])
      session[:news_item_id] = nil
      session[:pledge_amount] = nil
    end
  end

  helper_method :url_for_news_item
  def url_for_news_item(news_item)
    case news_item
    when Pitch
      pitch_path(news_item)
    when Tip
      tip_path(news_item)
    when Story
      story_path(news_item)
    end
  end

  def store_comment_for_non_logged_in_user
    title, body, commentable_id = params_for_comment(params)
    if title && body && commentable_id
      session[:return_to] = url_for_news_item(NewsItem.find_by_id(params[:commentable_id]))
      session[:title] = title
      session[:body] = body
      session[:news_item_id] = commentable_id
    end
  end

  def params_for_comment(comment_params)
    comment_params.symbolize_keys!
    if comment_params[:comment]
      comment_params[:comment].symbolize_keys!
      [comment_params[:comment][:title], comment_params[:comment][:body], comment_params[:commentable_id]]
    else
      [comment_params[:title], comment_params[:body], comment_params[:commentable_id]]
    end
  end

  def handle_comment_for_non_logged_in_user
    if session[:title] && session[:body] && session[:news_item_id]
      self.current_user.comments.create(:commentable_id => session[:news_item_id], :commentable_type => "NewsItem", :title => session[:title], :body => session[:body])
      session[:news_item_id] = nil
      session[:title] = nil
      session[:body] = nil
    end
  end

  layout :application_except_xhr
  def application_except_xhr
    request.xhr? ? false : "application"
  end

  def set_ajax_flash(type, message)
    if request.xhr?
      headers["X-Flash-#{type.to_s.capitalize}"] = message
    else
      flash[type] = message
    end
  end

  def flash_and_redirect(type, message, url = root_path)
    set_ajax_flash(type, message)
    if request.xhr?
      render :nothing => true
    else
      redirect_to url
    end
  end
  
  def check_for_cca_turk_for_pictures
    # get all answers by user...
    turk_answers = @cca.get_answers_by_user(current_user.id)
    if turk_answers.length >= @cca.maximum_turks_per_user || (turk_answers.length >= @cca.minimum_turks_per_user && params[:apply_now]) 
      credit = Credit.create(:user_id => current_user.id, :description => "Awarded for #{@cca.title} | #{@cca.id}", :amount => @cca.award_amount*turk_answers.length, :cca_id => @cca.id)
      return "/stories/almost-funded"
    else
      picture_ids_string = turk_answers.map(&:turkable_id).join(",")
      picture = Picture.random(@cca.id, picture_ids_string)
      unless picture.empty?
        return "/cca/#{@cca.id}/pictures/#{picture.first.id}"
      else
        credit = Credit.create(:user_id => current_user.id, :description => "Awarded for #{@cca.title} | #{@cca.id}", :amount => @cca.award_amount*turk_answers.length, :cca_id => @cca.id)
        return "/stories/almost-funded"
      end
    end
  end
  
end
