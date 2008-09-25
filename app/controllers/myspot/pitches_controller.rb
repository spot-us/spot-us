class Myspot::PitchesController < ApplicationController
  before_filter :login_required
  resources_controller_for :pitches, :only => :index
end
