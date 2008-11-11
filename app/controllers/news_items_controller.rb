class NewsItemsController < ApplicationController  
  include NewsItemsHelper
  
  def index
    get_news_items
  end
  
  def sort_options
    render :text => options_for_sorting(params.fetch(:news_item_type, "news_items"), params.fetch(:sort_by,"desc"))
  end
  
  def search
    get_news_items
    render :action => 'index'    
  end
  
  protected
  def get_news_items   
    unless params[:news_item_type].blank?
      params[:sort_by] = 'desc' unless %w(desc asc most_pledged most_funded almost_funded).include?(params[:sort_by])
      @news_items = params[:news_item_type].camelize.singularize.constantize.send(params[:sort_by]).paginate(:all, :page => params[:page])
    else
      @news_items = NewsItem.paginate :all, :page => params[:page],
                    :order => "created_at #{params.fetch(:sort_by, 'desc')}", :conditions => ["type in (?)", ['Pitch', 'Tip']]
    end
  end
end
