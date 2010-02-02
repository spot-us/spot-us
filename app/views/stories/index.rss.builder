xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot Us Stories#{get_network_name?}"
    xml.link request.url
    xml.description "These are the recently published stories from Spot.Us#{get_network_name?}"
    xml.language "en-us"
    xml.pubDate @stories.first.created_at.to_s(:rfc822)
    xml.lastBuildDate @stories.first.created_at.to_s(:rfc822)
    @stories.each do |story|
      xml.item do
        xml.title story.headline
        xml.author story.user.full_name
        xml.description truncate_words(story.extended_description, 45)
        xml.pubDate story.created_at.to_s(:rfc822)
        xml.link link_to story.headline, story
      end
    end
  end
end

