class Admin::GroupsController < ApplicationController
  resources_controller_for :groups
  before_filter :admin_required
  layout 'bare'

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_groups_path
      else
        render :action => 'new'
      end
    end
  end

  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_groups_path
      else
        render :action => 'edit'
      end
    end
  end

end
