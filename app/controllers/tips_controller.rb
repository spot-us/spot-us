class TipsController < ApplicationController
  resources_controller_for :tip

  private

  def new_resource
    current_user.tips.new((params[:tip] || {}).merge(:headline => params[:headline]))
  end
end
