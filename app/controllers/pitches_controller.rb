class PitchesController < ApplicationController
  before_filter :block_if_donated_to, :only => :edit
  resources_controller_for :pitch

  def block_if_donated_to
    pitch = find_resource(params[:id])
    if pitch.donated_to?
      access_denied(:flash => "You cannot edit a pitch that has donations.", 
                    :redirect => pitch_url(pitch)) 
    end
  end
end
