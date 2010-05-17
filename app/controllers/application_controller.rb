class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  filter_parameter_logging :password, :password_confirmation, :credit_card_number
  helper :all # include all helpers, all the time
  
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
  after_filter :async_posts
  
  map_resource :profile, :singleton => true, :class => "User", :find => :current_user
  
  META_DESCRIPTION = "Spot.Us enables the public to commission journalists to do investigations on important and perhaps overlooked stories. " + 
                  "We are an open source project, to pioneer \"community funded reporting.\""
  META_KEYWORDS = "journalism, reporting, community, local, news, open source, media, donation, creative commons"
  
  before_filter :set_fb_session
  
  after_filter :minify_html, :unless => Proc.new { Rails.env.development? }
  
  # may not need this
  helper_method :fb_session
  def fb_session
    session[:fb_session]
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
    @cca_header = Cca.cca_home.first
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
    current_user.fb_session ||= session[:fb_session]  if current_user && session[:fb_session]
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

  def set_cookie(name, options={})
    cookies[name.to_sym] = options.merge(:domain => DEFAULT_HOST)
  end
  
  def delete_cookie(name)
    cookies.delete(name.to_sym, :domain => DEFAULT_HOST)
  end

  def handle_first_donation_for_non_logged_in_user
    if session[:news_item_id] && session[:donation_amount]
      self.current_user.donations.create(:pitch_id => session[:news_item_id], :amount => session[:donation_amount])
      session[:news_item_id] = nil
      session[:donation_amount] = nil
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
  
end
