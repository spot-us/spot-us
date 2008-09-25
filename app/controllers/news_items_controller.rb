class NewsItemsController < ApplicationController

  def index
    @news_items = NewsItem.newest
  end

end
