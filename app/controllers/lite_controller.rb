class LiteController < ApplicationController

  def index
    @pitch = Pitch.find_by_id(params[:id])
    @action = params[:sub]
    @user = User.new(params[:user_id]) if @action=='register'
    render :layout=>"lite"
  end

  def test
    @pitch = Pitch.find_by_id(params[:id])
    render :layout=>"widget"
  end
  
end
