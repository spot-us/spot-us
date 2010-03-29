class LiteController < ApplicationController

  def index
    pitch_id = cookies[:spotus_lite] && cookies[:spotus_lite].blank? ? cookies[:spotus_lite] : params[:id]
    @pitch = Pitch.find_by_id(pitch_id)
    @action = params[:sub]
    @user = User.new(params[:user_id]) if @action=='register'
    render :layout=>"lite"
  end

  def test
    @pitch = Pitch.find_by_id(params[:id])
    render :layout=>"widget"
  end
  
end
