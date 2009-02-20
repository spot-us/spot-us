class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  filter_parameter_logging :password, :password_confirmation, :credit_card_number
  helper :all # include all helpers, all the time

  include AuthenticatedSystem
  include SslRequirement

  # cache_sweeper :home_sweeper, :except => [:index, :show]

  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :destroy]

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
    cookies[:current_user_full_name] = current_user.full_name
  end

  def can_create?
    true
  end

  def can_edit?
    true
  end

  def update_balance_cookie
    cookies[:balance_text] = render_to_string(:partial => 'shared/balance')
  end

end
