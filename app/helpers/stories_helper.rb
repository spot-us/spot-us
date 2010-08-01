module StoriesHelper
  def display_filters 
	["unfunded","almost-funded","funded"]
  end 

  def active_button(selected)
	result = ""
	if selected == "pitches"
		result = display_filters.include?(params[:filter]) ? " selected" : ""
	elsif selected == "stories"
		result = params[:filter] == "published" ? " selected" : ""
	elsif selected == "tips"
		result = params[:filter] == "suggested" ? " selected" : ""
	elsif selected == "channels"
		result = params[:controller] == "channels" ? " selected" : ""
	end
	result
  end

  def channels_filter
	if params[:controller] == "channels" && @channels.any?
		results = []
		@channels.each do |channel|
			if channel == @channel    
				results << ("<span>" + link_to(channel.title, channel_path(channel), :class => "active") + "</span>")
			else
				results << ("<span>" + link_to(channel.title, channel_path(channel)) + "</span>")
			end
		end
		return "<strong>filter:</strong>" + results.join("|")
	end	
  end

  def stories_filter(url_base, filters)
	if params[:controller] == "news_items" and display_filters.include?(params[:filter])
		results = []
		filters.each do |filter, name|
			if display_filters.include?(filter) 
				class_attr 	= 	@filter == filter ? ' class="active"' : ""
				results 	<< 	('<span onclick="location.href=\'' + url_base + '/' +  filter + '\';"><a' + class_attr + ' href="' +
				  				url_base + '/' + filter + '" title="' + name + '">' + name + '</a></span>')
			end
		end
		return "<strong>filter:</strong>" + results.join("|")
	end
  end

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
      if @story.editable_by?(user) && @story.peer_reviewer
        out << content_tag(:div, link_to(image_tag('send_to_editor.png', :class => 'send_to_editor'), 
        fact_check_story_path(@story), :method => :put), :class => 'centered')
      end
      if !@story.peer_reviewer
        out << content_tag(:div, link_to(image_tag('ready_for_publishing.png', :class => 'ready_for_publishing'), 
                                  accept_story_path(@story), :method => :put), :class => 'centered')
      end
        
    when 'fact_check' then
      if @story.fact_checkable_by?(user)
        out << content_tag(:div, link_to(image_tag('edit_in_gray.png', :class => 'edit'), edit_story_path(@story)), :class => 'centered')
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
