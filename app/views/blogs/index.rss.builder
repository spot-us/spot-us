xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.author post.user.full_name
        xml.description truncate_words(strip_html(post.body), 35)
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link pitch_post_path(post.pitch, post)
      end
    end
  end
end

