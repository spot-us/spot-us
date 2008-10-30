class NewsItemsController < ApplicationController

  def index
    @news_items = NewsItem.newest
  end
  
  def search
    @news_items = []
    if params[:news_item_types].nil?
      @news_items = NewsItem.newest 
    else
      params[:news_item_types].each do |news_item_type, value|      
        @news_items += (news_item_type.singularize.capitalize.constantize.find :all) if value == "1"
      end
    end
    @news_items
    render :action => 'index'
  end
    
end
