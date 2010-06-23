xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot.Us: #{@filter.titleize} Stories From #{get_inside_network_text(@network).titleize}"
    xml.link request.url
    xml.description "These are the #{@filter.downcase} stories from Spot.Us #{get_inside_network_text(@network)}."
    xml.language "en-us"
    parse_xml_created_at(xml, @news_items)
    @news_items.each do |news_item|
      apply_fragment ['search_rss_modified2_', news_item, @full] do 
        xml.item do
          xml.title news_item.headline
          xml.author news_item.user.full_name
          description = (news_item.short_description.blank? ? news_item.extended_description : news_item.short_description)
          xml.description @full ? description : truncate_words(strip_tags(description), 50) 
          xml.pubDate news_item.created_at.to_s(:rfc822)
          if news_item.type=='Pitch'
            xml.link pitch_path(news_item, {:only_path=>false})
          elsif news_item.type=='Story'
            xml.link story_path(news_item, {:only_path=>false})
          elsif news_item.type=='Tip'
            xml.link tip_path(news_item, {:only_path=>false})
          else
            xml.link news_item_path(news_item, {:only_path=>false})
          end
        end
      end
    end
  end
end

