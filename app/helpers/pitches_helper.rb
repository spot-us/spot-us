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
  
end
