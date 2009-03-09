class AffiliationsController < ApplicationController
  resources_controller_for :affiliations, :only => [:create, :destroy]

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Successfully attached your pitch to this tip"
      else
        flash[:error] = "There was an error attaching your pitch to this tip.  Contact David if you have questions"
      end
      redirect_to tip_path(params[:affiliation][:tip_id])
    end
  end

  protected
  def can_create?
    access_denied unless new_resource.createable_by?(current_user)
  end

end
