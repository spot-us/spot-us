class IncentivesController < ApplicationController
  
  resources_controller_for :incentive 

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully created the incentive'
        redirect_to pitch_path(@incentive.pitch)
      else
        flash[:error] = 'There was an error saving the incentive'
        render :action => 'new'
      end
    end
  end
  
  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = 'Successfully updated the incentive'
        redirect_to pitch_path(@incentive.pitch)
      else
        flash[:error] = 'There was an error updating the incentive'
        render :action => 'edit'
      end
    end
  end
  
  response_for :destroy do |format|
    format.html do
      redirect_to pitch_path(@pitch)
    end
  end
  
end
