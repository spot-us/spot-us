class Admin::PitchesController < ApplicationController
  before_filter :admin_required
  layout "bare"

  resources_controller_for :pitches, :only => [:index, :update, :destroy, :approve, :unapprove]

  response_for :update do |format|
    format.html{ redirect_to admin_pitches_path }
  end

  response_for :destroy do |format|
    format.html do
      flash[:success] = "It's gone, baby, gone!"
      redirect_to admin_pitches_path
    end
  end

  def fact_checker_chooser
    render :partial => 'fact_checker_chooser', :locals => { :pitch => current_pitch, :cancel => true }
  end

  def approve
    current_pitch.approve!
    flash[:success] = "You have approved the pitch '#{current_pitch.headline}'!"
    redirect_to :back
  end

  def unapprove
    current_pitch.unapprove!
    flash[:success] = "You have un-approved the pitch '#{current_pitch.headline}'!"
    redirect_to :back
  end


  protected
  def current_pitch
    @pitch ||= Pitch.find(params[:id])
  end
end
