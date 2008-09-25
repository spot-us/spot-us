class Myspot::PledgesController < ApplicationController
  before_filter :login_required
  resources_controller_for :pledges, :only => :index
end
