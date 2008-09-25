class TipsController < ApplicationController
  resources_controller_for :tip

  private

  def new_resource
    params[:tip] ||= {}
    params[:tip][:headline] = params[:headline] if params[:headline]
    current_user.tips.new(params[:tip])
  end
end
