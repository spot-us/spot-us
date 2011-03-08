class NewsItemsController < ApplicationController
  include NewsItemsHelper

  before_filter :load_networks, :only => [:index, :search]
  # before_filter :select_tab, :only => [:index, :search]

  def index
    respond_to do |format|
      format.html do
        get_items
      end
      format.xml do
        @ids_only = params[:id_list].to_s=='true'
        get_items
      end
      format.rss do
        get_items(10)
        render :layout => false
      end
    end
  end
  
  def sort_options
    render :text => options_for_sorting(
      params.fetch(:news_item_type, "news_items"),
      params.fetch(:sort_by, "desc")
    )
  end

  #keeping but redirecting to the right urls with 301s...
  def search
    case params[:sort_by]
    when "asc"
      filter = "unfunded"
    when "desc"
      filter = "unfunded"
    when "almost_funded"
      filter = "almost-funded"
    when "most_funded"
      filter = "unfunded" 
    end
    
    filter = "suggested" if params[:news_item_type] ==  "tips"

    redirect_to "/stories/#{filter}", :status=>301
    return
  end

  protected

  def get_items(limit=nil)
    @requested_page = params[:page] || 1                                          # allow pagination
    @topic_id = params[:topic_id] || -1                                           # for simplicity for the API
    @grouping_id = params[:grouping_id] || -1                                     # for simplicity for the API
    @channels = Channel.by_network(current_network)                               # get the channels
    @network = current_network                                                    # get the network
    @topic = params[:topic] ? Topic.find_by_seo_name(params[:topic]) : nil        # get the topic
    @filter = params[:filter] ? params[:filter] : 'unfunded'                      # get the filter
    @filter = "updates" if @filter=='posts'
    @full = params[:length]
    
    unless @filter=='updates'
      @news_items = NewsItem.get_stories(@requested_page, @topic_id, @grouping_id, @topic, @filter, current_network, limit) 
    else
      @news_items = Post.by_network(@current_network).paginate(:page => params[:page], :order => "posts.id desc", :per_page=>9)
    end
  end

  def load_networks
    @networks = Network.all
  end
  
end
