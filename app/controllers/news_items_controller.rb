class NewsItemsController < ApplicationController
  helper :sort
  include SortHelper
  
  def index
    sort_init 'created_at', :default_order => 'desc'
    sort_update
    @news_items = NewsItem.find :all, :order => sort_clause
  end
  
  def search
    sort_init 'created_at', :default_order => 'desc'
    sort_update
    @news_items = []
    if params[:news_item_types].nil?
      @news_items = NewsItem.newest 
    else
      @news_items = NewsItem.find :all,
                    :order => sort_clause,
                    :conditions => {
                      :type => params[:news_item_types].symbolize_keys!.collect do |item, value| 
                        item.to_s.capitalize
                      end
                    }
    end
    @news_items
    render :action => 'index'
  end
    
end
