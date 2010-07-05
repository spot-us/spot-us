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
    if ["assignments","pledges","donations","pitches","posts","tips","comments"].include?(params[:section])
      @tab = params[:section]
      if params[:section] != "donations"
        @items = User.find_by_id(@profile.id).send(params[:section]).paginate(:all, :page => params[:page], :per_page => 20, 
                 :order => "created_at desc")
      else
        @items = User.find_by_id(@profile.id).all_donations.paid.paginate(:all, :page => params[:page], :per_page => 20, 
                 :order => "created_at desc")
      end                                                                                                                                                                       
    else
      @tab = "show"
    end
    render :template => "/profiles/tab"
  end

end
