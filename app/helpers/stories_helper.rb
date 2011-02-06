module StoriesHelper
  def display_filters 
    ["unfunded","almost-funded","funded"]
  end 

  def active_button(selected)
    result = ""
    if selected == "pitches"
      result = display_filters.include?(params[:filter]) && !@topic ? " selected" : ""
    elsif selected == "stories"
      result = params[:filter] == "published" ? " selected" : ""
    elsif selected == "tips"
      result = params[:filter] == "suggested" ? " selected" : ""
    elsif selected == "topics"
      result = @topic ? " selected" : ""
    end
    result
  end
  
  def channels_filter
    if @channels.any?
      results = []
      @channels.each do |channel|
        if channel == @channel    
          results << ("<li>" + link_to(channel.title, channel_path(channel), :class => "currentFilter") + "</li>")
        else
          results << ("<li>" + link_to(channel.title, channel_path(channel)) + "</li>")
        end
      end
      return "<li class='filterName'>Browse By Topic:</li>" + results.join("<li class='filterSeparator'>|<li>")
    end	
  end

  def topics_filter
    results = []
    results << ("<li>" + link_to("All", "/stories/#{@filter}", :class => @topic ? "" : "currentFilter") + "</li>")
    Topic.all.each do |topic|
      if topic == @topic    
        results << ("<li>" + link_to(topic.name, "/stories/#{@filter}/#{topic.seo_name}", :class => "currentFilter") + "</li>")
      else
        results << ("<li>" + link_to(topic.name, "/stories/#{@filter}/#{topic.seo_name}") + "</li>")
      end
    end
    return "<li class='filterName'>Browse By Topic:</li>" + results.join("<li class='filterSeparator'>|<li>")
  end

  def stories_filter(url_base, filters)
    if params[:controller] == "news_items" and display_filters.include?(params[:filter])
      results = []
      filters.each do |filter, name|
        if display_filters.include?(filter) 
          class_attr 	= 	@filter == filter ? ' class="currentFilter"' : ""
          results 	<< 	('<li><a' + class_attr + ' href="' +
          url_base + '/' + filter + '" title="' + name + '">' + name + '</a></li>')
        end
      end
      return "<li class='filterName'>Filter:</li>" + results.join("<li class='filterSeparator'>|<li>")
    end
  end

  def supporters_count
    @story.pitch.supporters.size
  end

  def publishing_workflow_buttons_for(user)
    if user.admin? || @story.fact_checkable_by?(user) || @story.publishable_by?(user) || @story.editable_by?(user)
      out = '<ul class="publishingButtons">'
        out << content_tag(:li, link_to("Edit", edit_story_path(@story))) if (@story.draft? && @story.editable_by?(user)) || user.admin?
        case @story.status
          when 'draft' then
            out << content_tag(:li, link_to("Send To Editor", fact_check_story_path(@story), :method => :put)) if @story.editable_by?(user) && @story.peer_reviewer
            out << content_tag(:li, link_to("Ready To Publish", accept_story_path(@story), :method => :put)) if !@story.peer_reviewer
          when 'fact_check' then
            if @story.fact_checkable_by?(user)
              out << content_tag(:li, link_to("Edit", edit_story_path(@story)))
              out << content_tag(:li, link_to("Send Back To Reporter", reject_story_path(@story), :method => :put))
              out << content_tag(:li, link_to("Ready To Publish", accept_story_path(@story), :method => :put))
            end
          when 'ready' then
            out << content_tag(:li, link_to("Publish Story", publish_story_path(@story), :method => :put)) if @story.publishable_by?(user)
        end
      out << "</ul>"
    end
  end
end
