class HomesController < ApplicationController
  # caches_page :show

  def show
    @featured = Pitch.by_network(current_network).featured
    if @featured.any?
      @featured_pitch = @featured.first
    else
      @featured_pitch = Pitch.by_network(current_network).rand
    end
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
