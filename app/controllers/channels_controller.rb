class ChannelsController < ApplicationController
  before_filter :select_tab   
  before_filter :load_networks, :only => [:show]
  
  def show
    @channel = Channel.find(params[:id])
    @news_items = @channel.pitches.approved.paginate(:page => params[:page])
    @channels = Channel.by_network(current_network)
    respond_to do |format|
      format.rss do
        render :template => "/news_items/index.rss", :layout => false
      end
      format.html do
        render :template => "/news_items/index"
      end
    end
  end
  
  protected
  
  def load_networks
    @networks = Network.all
  end
  
  def select_tab
    @selected_tab = "pitches"
  end
end
