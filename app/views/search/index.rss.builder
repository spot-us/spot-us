xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot.Us: Search Results"
    xml.link request.url
    xml.description "These are the search results Spot.Us."
    xml.language "en-us"
    parse_xml_created_at(xml, @items)
    @items.each do |item|
      apply_fragment ['search_rss_', item] do 
        if item.is_a?(Pitch) || item.is_a?(Story) || item.is_a?(Tip)
          xml.item do
            xml.title item.headline
            xml.author item.user.full_name
            description = (item.short_description.blank? ? item.extended_description : item.short_description)
            xml.description truncate_words(strip_tags(description), 50) 
            xml.pubDate item.created_at.to_s(:rfc822)
            if item.type=='Pitch'
              xml.link pitch_path(item, {:only_path=>false})
            elsif item.type=='Story'
              xml.link story_path(item, {:only_path=>false})
            elsif item.type=='Tip'
              xml.link tip_path(item, {:only_path=>false})
            else
              xml.link item_path(item, {:only_path=>false})
            end
          end
        elsif item.is_a?(User)
          xml.item do
            xml.title item.full_name
            xml.author "Spot.Us"
            xml.description truncate_words(strip_tags(item.about), 50) 
            xml.pubDate item.created_at.to_s(:rfc822)
            xml.link profile_path(item, {:only_path=>false})
          end
        elsif item.is_a?(Post)
          xml.item do
            xml.title item.title
            xml.author item.user.full_name
            xml.description truncate_words(strip_tags(body), 50) 
            xml.pubDate item.created_at.to_s(:rfc822)
            xml.link pitch_post_path(item.pitch, item, {:only_path=>false})
          end
        end
      end
    end
  end
end

