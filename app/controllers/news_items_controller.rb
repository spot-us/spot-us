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
    model_name = params[:news_item_type]
    raise "Can only search for valid news item types" and return unless %w(tip pitch news_item).include?(model_name)
    model = model_name.classify.constantize
    model.sort_by(params[:sort_by]).paginate(:all, :page => params[:page])
  end
end
