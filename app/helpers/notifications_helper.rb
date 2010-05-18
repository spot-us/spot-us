module NotificationsHelper
    def social_notify_header(notify_type, notify_object)
        if notify_type == "donation"
			%Q{<h3>Nice donation to '#{notify_object.pitch.headline}'!</h3>
			<hr>
			<div class="panel">
				Would you like to share the news of your donation?<br/>}
		elsif notify_type == "post"
			%Q{<h3>Nice blog post on '#{notify_object.pitch.headline}'!</h3>
			<hr>
			<div class="panel">
				Would you like to share your post?<br/>}
		end
	end
	
	def social_notify_form_attrs(notify_type, notify_object)
	    if notify_type == "donation"
	        %Q{<input type="hidden" name="subject" value="Hey, I made a donation to '#{notify_object.pitch.headline}' on Spot.Us">
	        <input type="hidden" name="message" 
	        value="Hi,\nCheck out the pitch I donated to at Spot.Us.\n\nvisit:\n#{pitch_url(notify_object.pitch)}\n\nThanks,\n#{notify_object.user.full_name}">}
	    elsif notify_type == "post"
	        %Q{<input type="hidden" name="subject" value="Hey, I created a new blog post for the pitch '#{notify_object.pitch.headline}' on Spot.Us">
	        <input type="hidden" name="message" 
	        value="Hi,\nCheck out my new blog post '#{notify_object.title}' at Spot.Us.\n\nvisit:\n#{pitch_post_url(notify_object.pitch, notify_object)}\n\nThanks,\n#{notify_object.user.full_name}">}
        end
    end
end
