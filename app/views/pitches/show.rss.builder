xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    limit = 10
    case @tab.strip.downcase
      when 'posts'
        @pitch.posts.find(:all,:limit=>limit).each do |post|
          xml.item do
            xml.title post.title
            xml.description post.body
            xml.pubDate post.created_at.to_s(:rfc822)
            xml.link pitch_post_path(@pitch, post)
          end
        end
      when 'comments'
        @pitch.comments.find(:all,:limit=>limit).each do |comment|
          xml.item do
            xml.title comment.title
            xml.description comment.body
            xml.pubDate comment.created_at.to_s(:rfc822)
            xml.link pitch_path(@pitch)+"/comments##{comment.id}"
          end
        end
      when 'assignments'
        @pitch.assignments.find(:all,:limit=>limit).each do |assignment|
          xml.item do
            xml.title assignment.title
            xml.description assignment.body
            xml.pubDate assignment.created_at.to_s(:rfc822)
            xml.link pitch_assigment_path(@pitch, assignment)
          end
        end
      else
        @pitch.posts.find(:all,:limit=>limit).each do |post|
          xml.item do
            xml.title post.title
            xml.description post.body
            xml.pubDate post.created_at.to_s(:rfc822)
            xml.link pitch_post_path(@pitch, post)
          end
        end
      end
  end
end

