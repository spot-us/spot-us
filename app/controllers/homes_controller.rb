class HomesController < ApplicationController
  # caches_page :show

  def show
    @featured_pitch = Pitch.featured.first
  end
  
  def start_story
    if !logged_in?
      session[:return_to] = start_story_path
      redirect_to new_session_path
    elsif logged_in? && current_user.is_a?(Reporter)
      redirect_to new_pitch_path
    else
      redirect_to new_tip_path
    end
  end

end
