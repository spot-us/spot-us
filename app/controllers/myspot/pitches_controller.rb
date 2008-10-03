class Myspot::PitchesController < ApplicationController
  before_filter :login_required
  resources_controller_for :pitches, :only => :index

  def accept 
    pitch = find_resource(params[:id])
    pitch.accept!
    flash[:notice] = "You have accepted the pitch."
    redirect_to myspot_pitches_url
  end

  private

  def find_resources
    current_user.pitches
  end
end
