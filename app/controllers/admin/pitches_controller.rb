class Admin::PitchesController < ApplicationController
  before_filter :admin_required
  layout "bare"
  
  resources_controller_for :pitches, :only => :index
  
end