class ProfilesController < ApplicationController
  #resources_controller_for :profiles, :class => User #, :only => [:show]
  #before_filter :redirect_appropriately, :except => [:show]
  before_filter :get_profile
  private
  


  def redirect_appropriately
    redirect_to(logged_in? ? myspot_profile_path : root_path)
  end
  
  def get_profile
    @profile = User.find(params[:id])
    @tab = params[:action]
    render :template => "/profiles/tab"
  end

end
