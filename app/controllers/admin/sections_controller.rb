class Admin::SectionsController < ApplicationController
  before_filter :admin_required
  layout "bare"
  resources_controller_for :sections
  
  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfuly created a new help section!"
        redirect_to admin_sections_path
      else
        render :action => 'new'
      end
    end
  end
  
  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "You have successfully edited the help section!"
        redirect_to admin_sections_path
      else
        render :action => 'edit'
      end
    end
  end

  response_for :destroy do |format|
    format.html do
      flash[:success] = "It's gone, baby, gone!"
      redirect_to admin_sections_path
    end
  end

  protected
  
  def current_section
    @section ||= Section.find(params[:id])
  end
end
