xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
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

