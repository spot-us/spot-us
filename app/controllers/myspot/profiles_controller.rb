class Myspot::ProfilesController < ApplicationController

  before_filter :login_required

  resources_controller_for :profile,
                           :class     => User,
                           :singleton => true,
                           :only      => [:edit, :update, :show] do
    current_user
  end
  
  def edit
    @profile = find_resource
     if request.xhr?
       render :partial => 'users/fb_popup_form'
     end
  end
  
  def update
    self.resource = find_resource
    resource.attributes = params[resource_name]
    if resource_saved?
      create_current_login_cookie
      update_balance_cookie
      if request.xhr?
        render :nothing => true
      else
        flash[:notice] = "Your profile was updated."
        redirect_to edit_myspot_profile_path
      end
    else
      if request.xhr?
        render :partial => 'users/fb_popup_form', :status => :unprocessable_entity
      else
        flash[:error] = "Your profile was not updated."
        redirect_to edit_myspot_profile_path
      end
    end
  end
  
end
