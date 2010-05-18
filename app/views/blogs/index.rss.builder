xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    @posts.each do |post|
      apply_fragment ['blog_post_rss_modified_', post, @full] do
        xml.item do
          xml.title post.title
          xml.author post.user.full_name
          if @full
            xml.description post.body
          else
            xml.description truncate_words(strip_html(post.body), 35)
          end
          xml.pubDate post.created_at.to_s(:rfc822)
          xml.link pitch_post_path(post.pitch, post, {:only_path=>false})
        end
      end
    end
  end
end

