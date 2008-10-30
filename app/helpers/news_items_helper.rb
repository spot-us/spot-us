module NewsItemsHelper
  def check_box_checked_for?(value)
    if !params[:news_item_types].nil?
      (request.post? || session[@sort_name]) && !params[:news_item_types][value].nil? ? params[:news_item_types][value].any? : false
    else
      false
    end
  end
  
  def newest_sort
    if !params[:news_item_types].nil?
      {:params => {:news_item_types => params[:news_item_types], :order => 'asc'}}
    else
      {:params => {:order => 'asc'}}
    end
  end
  
  def oldest_sort
    if !params[:news_item_types].nil?
      {:params => {:news_item_types => params[:news_item_types], :order => 'desc'}}
    else
      {:params => {:order => 'desc'}}
    end
  end

end
