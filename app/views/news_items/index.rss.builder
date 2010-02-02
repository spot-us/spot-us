xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot Us News Items" ##{get_network_name?}
    xml.link request.url
    xml.description "These are the recently published news items from Spot.Us"
    xml.language "en-us"
    xml.pubDate @news_items.first.created_at.to_s(:rfc822)
    xml.lastBuildDate @news_items.first.created_at.to_s(:rfc822)
    @news_items.each do |news_item|
      xml.item do
        xml.title news_item.headline
        xml.author news_item.user.full_name
        xml.description news_item.short_description
        xml.pubDate news_item.created_at.to_s(:rfc822)
        xml.link url_for_news_item(news_item)
      end
    end
  end
end

