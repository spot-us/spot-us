class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  filter_parameter_logging :password, :password_confirmation, :credit_card_number
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include SslRequirement
  
  cache_sweeper :home_sweeper, :except => [:index, :show]

  helper_method :start_story_path

  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :destroy]
  
  map_resource :profile, :singleton => true, :class => User, :find => :current_user

  protect_from_forgery

  def start_story_path
    if logged_in? && Reporter === current_user
      new_pitch_path
    else
      new_tip_path
    end
  end

  protected
  
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
      return if not logged_in?    
      cookies[:balance_text] = render_to_string(:partial => 'layouts/balance')
    end
  
end
