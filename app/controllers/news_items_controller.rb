class NewsItemsController < ApplicationController
  include NewsItemsHelper

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
    @news_items = NewsItem.by_sort(params[:news_item_type] || 'pitch', params[:sort_by]).paginate(:all, :page => params[:page])
  end
end
