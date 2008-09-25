class DonationsController < ApplicationController

  before_filter :login_required
  skip_before_filter :verify_authenticity_token
  resources_controller_for :donations, :only => :create

  def create
    self.resource = new_resource

    respond_to do |format|
      if resource.save
        format.js { render :partial => "added" }
      else
        format.js { render :partial => "new" }
      end
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
