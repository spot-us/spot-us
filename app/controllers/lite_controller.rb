class LiteController < ApplicationController

  def index
    
    # get the pitch using the ID or the cookie - ID overrides the cookie
    pitch_id = nil
    pitch_id = cookies[:spotus_lite] unless !cookies[:spotus_lite] || cookies[:spotus_lite].blank?
    pitch_id = params[:id] if params[:id]
    @pitch = pitch_id && !pitch_id.blank? ? Pitch.find_by_id(pitch_id) : Pitch.featured_by_network(current_network).first
    
    @pitch = Pitch.featured_by_network(current_network).first unless @pitch
    
    # save the pitch id so that we can keep track of which pitch we are on...
    cookies[:spotus_lite] = {
      :value => @pitch.id,
      :expires => 10.minutes.from_now
    }
    if params[:host]
      host = URI.decode(params[:host])
      host_arr = host.split('/')
      domain = host_arr[0..2].join('/')
      path = URI.encode(host.gsub(domain,''))
      # save the host
      cookies[:spotus_lite_host] = {
        :value => host,
        :expires => 2.hours.from_now
      } 
    end
    
    # handle some different cases
    @action = params[:sub]
    @user = User.new(params[:user_id]) if @action=='register'
    render :layout=>"lite"
  end

  def test
    @pitch = Pitch.find_by_id(params[:id])
    render :layout=>false
  end
  
end