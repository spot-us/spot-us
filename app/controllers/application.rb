# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  helper_method :start_story_path

  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update]

  protect_from_forgery # :secret => '5e89a8607a729450f876d58cf6d92b8b'

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
