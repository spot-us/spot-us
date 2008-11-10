module StoriesHelper
  def supporters_count
    @story.pitch.supporters.size
  end
  
  def publishing_workflow_buttons_for(user)
    out = "<div class='centered'>"
    if (@story.draft? && @story.editable_by?(user)) || user.admin?
      out << content_tag(:a, tag(:img, :class => 'edit'), :href => '')
    end
    case @story.status
    when 'draft' then
      if @story.editable_by?(user)
        out << content_tag(:a, tag(:img, :class => 'send_to_editor'), :href => '')
      end
    when 'fact_check' then
      if @story.fact_checkable_by?(user)
        out << content_tag(:a, tag(:img, :class => 'return_to_journalist'), :href => '')
        out << content_tag(:a, tag(:img, :class => 'ready_for_publishing'), :href => '')
      end      
    when 'ready' then
      if @story.publishable_by?(user)
        out << content_tag(:a, tag(:img, :class => 'publish'), :href => '')
      end
    end
    out << "</div>"
  end
end