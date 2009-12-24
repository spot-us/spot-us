class Admin::ChannelsController < ApplicationController
  resources_controller_for :channels
  before_filter :admin_required
  layout 'bare'

  response_for :create do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_channels_path
      else
        render :action => 'new'
      end
    end
  end

  response_for :update do |format|
    format.html do
      if resource_saved?
        flash[:success] = "Success!"
        redirect_to admin_channels_path
      else
        render :action => 'edit'
      end
    end
  end
  
  def show
    @channel = Channel.find(params[:id])
    @selectable_pitches = Pitch.browsable - @channel.pitches
  end
  
  def add_pitch
    @pitch = Pitch.find(params[:pitch_id])
    @channel = Channel.find(params[:id])
    @channel.pitches << @pitch
    redirect_to admin_channel_path(@channel)
  end
  
  def remove_pitch
    @pitch = Pitch.find(params[:pitch_id])
    @channel = Channel.find(params[:id])
    @channel.pitches.delete(@pitch)
    redirect_to admin_channel_path(@channel)
  end

end
