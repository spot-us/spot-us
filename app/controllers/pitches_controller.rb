class PitchesController < ApplicationController
  before_filter :store_location, :only => :show
  resources_controller_for :pitch

  def feature
    pitch = find_resource
    pitch.make_featured
    redirect_to pitch_path(pitch)
  end
  
  protected
    
  def can_create?
    access_denied unless Pitch.createable_by?(current_user)
  end

  def can_edit?
    
    pitch = find_resource
    
    if not pitch.editable_by?(current_user)
      if pitch.user == current_user
        if pitch.donated_to?
          access_denied( \
            :flash => "You cannot edit a pitch that has donations.  For minor changes, contact info@spot.us", 
            :redirect => pitch_url(pitch))
        else
          access_denied( \
            :flash => "You cannot edit this pitch.  For minor changes, contact info@spot.us", 
            :redirect => pitch_url(pitch))
        end
      else
        access_denied( \
          :flash => "You cannot edit this pitch, since you didn't create it.",
          :redirect => pitch_url(pitch))
      end
    end
  end

  def new_resource
    params[:pitch] ||= {}
    params[:pitch][:headline] = params[:headline] if params[:headline]
    current_user.pitches.new(params[:pitch])
  end
  
end
