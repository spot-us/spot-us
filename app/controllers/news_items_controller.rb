class NewsItemsController < ApplicationController
  include NewsItemsHelper

  before_filter :load_networks, :only => [:index, :search]

  def index
    get_news_items
  end

  def sort_options
    render :text => options_for_sorting(
      params.fetch(:news_item_type, "news_items"),
      params.fetch(:sort_by, "desc")
    )
  end

  def search
    get_news_items
    render :action => 'index'
  end

  protected

  def get_news_items
    model_name = params[:news_item_type]
    model_name = 'pitches' unless %w(tips pitches news_items).include?(model_name)
    model = model_name.classify.constantize
    @news_items = model.with_sort(params[:sort_by]).by_network(current_network).paginate(:page => params[:page])
  end

  def load_networks
    @networks = Network.all
  end
end
