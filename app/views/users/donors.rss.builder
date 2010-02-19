xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot.Us: Donors From #{get_inside_network_text(@network).titleize}"
    xml.link request.url
    xml.description "These are the donors from Spot.Us inside #{get_inside_network_text(@network)}."
    xml.language "en-us"
    parse_xml_created_at(xml, @donations)
    @donations.each do |donation|
      xml.item do
        xml.title donation.user.full_name
        xml.author donation.user.full_name
        xml.description truncate_words(strip_tags((donation.user.about_you.blank? ? "The donor #{donation.user.full_name} has not added their about you section yet" : donation.user.about_you)), 50)
        xml.pubDate donation.user.created_at.to_s(:rfc822)
        xml.link profile_path(donation.user)
      end
    end
  end
end

