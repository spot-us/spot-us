class NewsItemsController < ApplicationController
  include NewsItemsHelper

  before_filter :load_networks, :only => [:index, :search]
  # before_filter :select_tab, :only => [:index, :search]

  def index
    @channels = Channel.by_network(current_network)
    @network = current_network
    @topic = params[:topic] ? Topic.find_by_seo_name(params[:topic]) : nil
    @full = (params[:length]=='full')
    get_filter
    respond_to do |format|
      format.html do
        get_news_items
      end
      format.xml do
        get_news_items
      end
      format.rss do
        get_news_items(10)
        render :layout => false
      end
    end
  end
  
  def get_filter
    @filter = params[:filter] ? params[:filter] : 'unfunded'
  end
  protected :get_filter
  
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

  def get_news_items(limit=nil)
    @requested_page = params[:page] || 1
    unless limit
      @news_items = NewsItem.constrain_type(@filter).constrain_topic(@topic).send(@filter.gsub('-','_')).order_results(@filter).browsable.by_network(current_network).paginate(:page => params[:page])
    else
      @news_items = NewsItem.constrain_type(@filter).constrain_topic(@topic).send(@filter.gsub('-','_')).order_results(@filter).browsable.by_network(current_network).find(:all,:limit=>limit)
    end
  end

  def load_networks
    @networks = Network.all
  end
  # 
  # def select_tab
  #   @selected_tab = "pitches"
  # end
end
