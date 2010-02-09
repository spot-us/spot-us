module PitchesHelper
  def citizen_supporters_for(pitch)
    pitch.supporters - pitch.donations_and_credits.from_organizations.map(&:user)
  end
  
  def active_tab_class?(tab, tab_try)
    return (active_tab?(tab, tab_try) ? " active" : "")
  end
  
  def active_tab?(tab, tab_try)
    (tab==tab_try)
  end
  
  def pre_title?(item)
    if item.is_a?(Post)
			"Story Update"
		elsif item.is_a?(Assignment)
			"Assignment" 
		elsif item.is_a?(Comment)
			"Comment"
		else
		   "Unknown"
		end
  end
  
  def pre_title_rss_feed?(tab)
    return tab=='posts' ? 'Story Updates' : tab.capitalize
  end
  
  def parse_xml_created_at(xml, posts)
    if posts
      xml.pubDate posts.first.created_at.to_s(:rfc822) 
      xml.lastBuildDate posts.first.created_at.to_s(:rfc822)
    else
      xml.pubDate Time.now.to_s(:rfc822) 
      xml.lastBuildDate Time.now.to_s(:rfc822)
    end
  end
  
end
