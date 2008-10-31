class NewsItemsController < ApplicationController  
  def index
    get_news_items
  end
  
  def search
    get_news_items
    render :action => 'index'    
  end
  
  protected
  def get_news_items
    unless params[:news_item_types].blank? 
      @news_items = NewsItem.find :all,
                    :order => "created_at #{params.fetch(:date_sort, 'desc')}",
                    :conditions => {
                      :type => params[:news_item_types].symbolize_keys!.collect do |item, value| 
                        item.to_s.capitalize
                      end
                      }
    else
      @news_items = NewsItem.find :all,
                    :order => "created_at #{params.fetch(:date_sort, 'desc')}"
    end
  end
end
