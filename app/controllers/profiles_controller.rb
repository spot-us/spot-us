class ProfilesController < ApplicationController
  resources_controller_for :profiles, :class => User, :only => [:show]
  before_filter :redirect_appropriately, :except => [:show]

  private

  def redirect_appropriately
    redirect_to(logged_in? ? myspot_profile_path : root_path)
  end

end
