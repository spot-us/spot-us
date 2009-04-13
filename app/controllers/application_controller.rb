class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  filter_parameter_logging :password, :password_confirmation, :credit_card_number
  helper :all # include all helpers, all the time

  include AuthenticatedSystem
  include SslRequirement

  # cache_sweeper :home_sweeper, :except => [:index, :show]

  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :destroy]
  before_filter :current_network

  map_resource :profile, :singleton => true, :class => "User", :find => :current_user

  protect_from_forgery

  def current_network
    subdomain = current_subdomain.downcase if current_subdomain
    @current_network ||= Network.find_by_name(subdomain)
  end

  protected

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

end
