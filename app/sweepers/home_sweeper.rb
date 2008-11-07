class HomeSweeper < ActionController::Caching::Sweeper
  observe NewsItem
  
  def after_save(news_item)
    expire_pages
  end
  
  def after_destroy(news_item)
    expire_pages
  end
  
  private
    
    def expire_pages
      expire_page(:controller => 'homes', :action => 'show')
      expire_page(:controller => 'news_items', :action => 'index')
    end

end