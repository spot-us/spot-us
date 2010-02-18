class NotificationsController < ApplicationController
  
  def index
    #nothing here if you have the wrong hash to pass in here :-)
    unless params[:code]==APP_CONFIG[:cron_job_code]
      response.headers["Status"] = "404 Page Not Found"
      render :text=>"Ooops, something doesn't exist there."
      return
    end
    notify_pitch_owners
    render :text=>"ok!" 
  end
  
  private
  
  def notify_pitch_owners
    posts = Post.find(:all, :conditions=> "created_at>='#{1.year.ago}'" ).map(&:pitch_id).uniq
    Pitch.unfunded.find(:all, :conditions => "id not in (#{posts.join(',')})").each do |pitch|
      Mailer.deliver_create_blog_post_notification(pitch)
    end
    return
  end
  
end
