class HomesController < ApplicationController
  # caches_page :show
  include OauthConnect
  def show
    @featured_pitches = Pitch.featured_by_network(current_network)
    @featured_stories = Story.published.latest
    @posts = Post.by_network(@current_network).latest
    
    #############  TEST FOR POSTING TO FB WALL
    # access_token = fb_access_token(session[:fb_session], request.url) 
    # fb_wall_publish(access_token, { :message      => "Fortune is real.... is lonely",
    #                                 :description  => "it's real if you look closely",
    #                                 :link         => "http://spot.us",
    #                                 :picture      => "http://photos-d.ak.fbcdn.net/hphotos-ak-snc3/hs522.snc3/29731_391647542444_646187444_3907874_6050715_s.jpg",
    #                                 :name         => "Merton Hanks"  
    # })
  end

  def start_story
    if !logged_in?
      session[:return_to] = start_story_path
      redirect_to new_session_path
    elsif logged_in? && current_user.is_a?(Reporter) || current_user.is_a?(Organization)
      redirect_to new_pitch_path
    else
      redirect_to new_tip_path
    end
  end
  
end
