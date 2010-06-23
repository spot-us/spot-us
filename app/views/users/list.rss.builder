xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot.Us: #{@filter.gsub("_", " ").gsub("-", " ").titleize} From #{get_inside_network_text(@network).titleize}"
    xml.link request.url
    xml.description "These are the #{@filter.gsub("_", " ").gsub("-", " ").titleize} from Spot.Us #{get_inside_network_text(@network)}."
    xml.language "en-us"
    parse_xml_created_at(xml, @items)
    @items.each do |item|
      if item
        xml.item do
          xml.title item.user.full_name
          xml.author item.user.full_name
          xml.description truncate_words(strip_tags((item.user.about_you.blank? ? "The donor #{item.user.full_name} has not added their about you section yet" : item.user.about_you)), 50)
          xml.pubDate item.user.created_at.to_s(:rfc822)
          xml.link profile_path(item.user, {:only_path=>false})
        end
      end
    end
  end
end

