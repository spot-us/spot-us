module HomesControllerHelper
  def get_more_link(selected_filter)
    if selected_filter=='featured'
      link_to "see other unfunded stories", "/stories/unfunded"
    elsif selected_filter=='published'
      link_to "see more published stories", "/stories/published"
    elsif selected_filter=='funded'
      link_to "see other funded stories", "/stories/funded"
    elsif selected_filter=='updates'
      link_to "see other story updates", "/stories/updates"
    end
  end
end
