xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot.Us: Donors From #{get_inside_network_text(@network).titleize}"
    xml.link request.url
    xml.description "These are the donors from Spot.Us inside #{get_inside_network_text(@network)}."
    xml.language "en-us"
    parse_xml_created_at(xml, @pitches)
    @pitches.each do |pitch|
      xml.item do
        xml.title pitch.user.full_name
        xml.author pitch.user.full_name
        xml.description truncate_words(strip_tags((pitch.user.about_you.blank? ? "The donor #{pitch.user.full_name} has not added their about you section yet" : pitch.user.about_you)), 50)
        xml.pubDate pitch.user.created_at.to_s(:rfc822)
        xml.link profile_path(pitch.user)
      end
    end
  end
end

