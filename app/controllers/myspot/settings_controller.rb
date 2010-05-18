class Myspot::SettingsController < ApplicationController

  before_filter :login_required

  resources_controller_for :settings,
                           :class     => User,
                           :singleton => true,
                           :only      => [:edit, :update] do
    current_user
  end

  def update
    self.resource = find_resource
    resource.attributes = params[resource_name]
    if resource_saved?
      flash[:success] = 'Your settings have been saved.'
      redirect_to params[:return_to] || edit_myspot_settings_path
    else
      render :action => 'edit'
    end
  end

end
