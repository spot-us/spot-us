module PitchesHelper
  def citizen_supporters_for(pitch)
    pitch.supporters - pitch.donations_and_credits.from_organizations.map(&:user)
  end
  
  def via_cca_supporters_for(pitch)
    Donation.cca_supporters(pitch.id)
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
  
end
