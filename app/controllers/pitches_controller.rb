class PitchesController < ApplicationController
  # before_filter :block_if_donated_to, :only => :edit
  resources_controller_for :pitch

  # def block_if_donated_to
  #   access_denied if find_resource(params[:id]).donated_to?
  # end
end
