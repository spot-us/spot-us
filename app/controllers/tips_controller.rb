class TipsController < ApplicationController
  resources_controller_for :tip, :except => :destroy

  private

  def can_edit?
    access_denied unless find_resource.editable_by?(current_user)
  end

  def can_create?
    access_denied unless Tip.createable_by?(current_user)
  end

  def new_resource
    params[:tip] ||= {}
    params[:tip][:headline] = params[:headline] if params[:headline]
    current_user.tips.new(params[:tip])
  end
end
