class DonationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  resources_controller_for :donations

  def create
    self.resource = new_resource

    respond_to do |format|
      if resource.save
        format.js { render :partial => "create" }
      else
        format.js { render :partial => "new" }
      end
    end
  end
  

  protected

  def new_resource
    current_user.donations.new(params[:donation])
  end

  def find_resources
    current_user.donations.unpaid
  end
end
