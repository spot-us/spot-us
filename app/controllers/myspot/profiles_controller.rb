class Myspot::ProfilesController < ApplicationController

  before_filter :login_required

  resources_controller_for :profile,
                           :class     => User,
                           :singleton => true,
                           :only      => [:edit, :update, :show] do
    current_user
  end
  
  # response_for :edit do |format|
  #   if request.xhr?
  #     #render :partial => 'users/popup_form', :status => :unprocessable_entity and return false
  #   else
  #     render :partial => 'users/popup_form', :status => :unprocessable_entity and return false
  #   end
  # end
  
  def edit
    @profile = find_resource
     if request.xhr?
       render :partial => 'users/popup_form', :status => :unprocessable_entity
     else
       #render :partial => 'users/popup_form', :status => :unprocessable_entity
     end
  end
  
end
