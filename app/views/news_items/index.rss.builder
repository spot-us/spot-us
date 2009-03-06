xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    @news_items.each do |news_item|
      xml.item do
        xml.title news_item.headline
        xml.description news_item.short_description
        xml.pubDate news_item.created_at.to_s(:rfc822)
        xml.link url_for_news_item(news_item)
      end
    end
  end
end

