class DonationsController < ApplicationController
  before_filter :login_required
  resources_controller_for :donations, :only => :create

  response_for :create do |format|
    if resource_saved?
      format.js
    else
      format.js { render :action => "new"}
    end
  end

  
  protected

  def can_create?
    access_denied unless Donation.createable_by?(current_user)
  end

  def new_resource
    current_user.donations.new(params[:donation])
  end

  def find_resources
    current_user.donations.unpaid
  end
end
