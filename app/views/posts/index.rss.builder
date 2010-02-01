xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    @pitch.posts.each do |post|
      xml.item do
        xml.title post.title
        xml.author post.user.full_name
        xml.description truncate_words(post.body, 45)
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link link_to h(post.title), pitch_post_path(@pitch, post)
      end
    end
  end
end

