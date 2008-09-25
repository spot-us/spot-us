# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  helper_method :start_story_path

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '5e89a8607a729450f876d58cf6d92b8b'

  def start_story_path
    if logged_in? && Reporter === current_user
      new_pitch_path
    else
      new_tip_path
    end
  end
end
