class PledgesController < ApplicationController
  resources_controller_for :pledges

  def create
    self.resource = new_resource

    respond_to do |format|
      if resource.save
        format.js
      else
        format.js { render :partial => "new" }
      end
    end
  end
  

  protected

  def new_resource
    current_user.pledges.new(params[:pledge])
  end
end
