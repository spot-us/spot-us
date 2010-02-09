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
    # add relation for channel/network if available
    cn = ChannelsNetwork.find_by_network_id_and_channel_id(@pitch.network_id, @channel.id)
    unless cn
      cn = ChannelsNetwork.new
      cn.network_id = @pitch.network_id
      cn.channel_id = @channel.id
      cn.save
    end
    redirect_to admin_channel_path(@channel)
  end
  
  def remove_pitch
    @pitch = Pitch.find(params[:pitch_id])
    @channel = Channel.find(params[:id])
    @channel.pitches.delete(@pitch)
    # clean up the channel/network associations
    network_ids = @channel.pitches.find(:all, :select=>"network_id, channel_pitches.created_at as created_at").map(&:network_id).join(",")
    ChannelsNetwork.delete_all(["network_id not in (?) and channel_id=?", network_ids, @channel.id])
    redirect_to admin_channel_path(@channel)
  end

end
