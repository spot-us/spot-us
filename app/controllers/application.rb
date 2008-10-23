class ApplicationController < ActionController::Base
  filter_parameter_logging :password, :credit_card_number
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

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

  def can_create?
    true
  end

  def can_edit?
    true
  end
  
end
