class NewsItemsController < ApplicationController
  include NewsItemsHelper

  before_filter :load_networks, :only => [:index, :search]
  before_filter :select_tab, :only => [:index, :search]

  def index
    @channels = Channel.by_network(current_network)
    respond_to do |format|
      format.rss do
        @news_items = NewsItem.newest.first(10)
        render :layout => false
      end
      format.html do
        get_news_items
      end
    end
  end

  def sort_options
    render :text => options_for_sorting(
      params.fetch(:news_item_type, "news_items"),
      params.fetch(:sort_by, "desc")
    )
  end

  def search
    @channels = Channel.by_network(current_network)
    @filter = "newest_stories"
    case params[:sort_by]
    when "asc"
      @filter = "newest_stories"
    when "desc"
      @filter = "oldest_stories"
    when "almost_funded"
      @filter = "almost_funded"
    when "most_funded"
      @filter = "most_pledged" 
    end
      
    get_news_items
    render :action => 'index'
  end

  protected

  def get_news_items
    model_name = params[:news_item_type]
    model_name = 'pitches' unless %w(tips pitches news_items).include?(model_name)
    model = model_name.classify.constantize
    @news_items = model.approved.with_sort(params[:sort_by]).exclude_type('story').by_network(current_network).paginate(:page => params[:page])
  end

  def load_networks
    @networks = Network.all
  end
  
  def select_tab
      @selected_tab = "pitches"
  end
end
