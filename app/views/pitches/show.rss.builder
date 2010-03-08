xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Spot Us Pitch: #{@pitch.headline} - #{pre_title_rss_feed?(@tab)}"
    xml.link "#{pitch_url(@pitch)}/#{@tab}"
    xml.description @pitch.short_description
    xml.language "en-us"
    limit = 10
    case @tab.strip.downcase
      when 'posts'
        posts = @pitch.posts.find(:all,:limit=>limit)
        parse_xml_created_at(xml, posts)
        posts.each do |post|
          apply_fragment ['pitch_rss_posts', post] do
            xml.item do
              xml.title post.title
              xml.description post.body
              xml.pubDate post.created_at.to_s(:rfc822)
              xml.link pitch_post_path(@pitch, post)
            end
          end
        end
      when 'comments'
        comments = @pitch.comments.find(:all,:limit=>limit)
        parse_xml_created_at(xml, comments)
        comments.each do |comment|
          apply_fragment ['pitch_rss_comments', comment] do
            xml.item do
              xml.title comment.title
              xml.description comment.body
              xml.pubDate comment.created_at.to_s(:rfc822)
              xml.link pitch_path(@pitch)+"/comments##{comment.id}"
            end
          end
        end
      when 'assignments'
        assignments = @pitch.assignments.find(:all,:limit=>limit)
        parse_xml_created_at(xml, assignments)
        assignments.each do |assignment|
          apply_fragment ['pitch_rss_assignments', assignment] do
            xml.item do
              xml.title assignment.title
              xml.description assignment.body
              xml.pubDate assignment.created_at.to_s(:rfc822)
              xml.link pitch_assignment_path(@pitch, assignment)
            end
          end
        end
      else
        posts = @pitch.posts.find(:all,:limit=>limit)
        parse_xml_created_at(xml, posts)
        posts.each do |post|
          apply_fragment ['pitch_rss_posts', post] do
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
end

