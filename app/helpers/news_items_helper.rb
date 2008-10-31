module NewsItemsHelper
  def check_box_checked_for?(value)
    unless params[:news_item_types].nil?
      !params[:news_item_types][value].nil? ? params[:news_item_types][value].any? : false
    else
      false
    end
  end
end
