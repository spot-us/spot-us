class Myspot::DonationsController < ApplicationController
  before_filter :login_required
  resources_controller_for :donations, :only => :index

  protected

  def find_resources
    current_user.donations.paid
  end
end
