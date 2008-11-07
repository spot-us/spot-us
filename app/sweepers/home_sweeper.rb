class HomeSweeper < ActionController::Caching::Sweeper
  observe NewsItem
  
  def after_save(news_item)
    expire_page(:controller => 'homes', :action => 'show')
  end
  
  def after_destroy(news_item)
    expire_page(:controller => 'homes', :action => 'show')
  end

end