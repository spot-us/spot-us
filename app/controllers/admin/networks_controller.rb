class Admin::NetworksController < ApplicationController
  resources_controller_for :networks

  before_filter :admin_required
  skip_before_filter :admin_required, :only => :categories
  layout "bare"

  response_for :create do |format|
    format.html do
      if resource_saved?
        redirect_to edit_admin_network_path(self.resource)
      else
        render :action => :new
      end
    end
  end

  response_for :update do |format|
    format.html do
      redirect_to edit_admin_network_path(self.resource)
    end
  end

  def categories
    respond_to do |format|
      format.json do
        render :json => Category.find_all_by_network_id(params[:id])
      end
    end
  end

end
