class Myspot::DonationsController < ApplicationController
  before_filter :login_required
  resources_controller_for :donations, :only => :index
end
