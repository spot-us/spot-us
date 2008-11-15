module StoriesHelper
  def supporters_count
    @story.pitch.supporters.size
  end

  def publishing_workflow_buttons_for(user)
    out = ""
    if (@story.draft? && @story.editable_by?(user)) || user.admin?
      out << content_tag(:div, link_to(image_tag('edit_in_gray.png', :class => 'edit'), edit_story_path(@story)), :class => 'centered')
    end
    case @story.status
    when 'draft' then
      if @story.editable_by?(user)
        out << content_tag(:div, link_to(image_tag('send_to_editor.png', :class => 'send_to_editor'), 
        fact_check_story_path(@story), :method => :put), :class => 'centered')
      end
    when 'fact_check' then
      if @story.fact_checkable_by?(user)
        out << content_tag(:div, link_to(image_tag('return_to_journalist.png', :class => 'return_to_journalist'), 
                                reject_story_path(@story), :method => :put), :class => 'centered')
        out << content_tag(:div, link_to(image_tag('ready_for_publishing.png', :class => 'ready_for_publishing'), 
                                  accept_story_path(@story), :method => :put), :class => 'centered')
      end
    when 'ready' then
      if @story.publishable_by?(user)
        out << content_tag(:div, link_to(image_tag('publish.png', :class => 'publish'), 
                                  publish_story_path(@story), :method => :put), :class => 'centered')
      end
    end
    out << ""
  end
end
