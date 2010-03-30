class LiteController < ApplicationController

  def index
    pitch_id = cookies[:spotus_lite] && cookies[:spotus_lite].blank? ? cookies[:spotus_lite] : params[:id]
    @pitch = pitch_id && pitch_id.blank? ? Pitch.find_by_id(pitch_id) : Pitch.featured_by_network(current_network).first
    cookies[:spotus_lite] = {
      :value => @pitch.id,
      :expires => 10.minutes.from_now
    }
    @action = params[:sub]
    @user = User.new(params[:user_id]) if @action=='register'
    render :layout=>"lite"
  end

  def test
    @pitch = Pitch.find_by_id(params[:id])
    render :layout=>"widget"
  end
  
end
