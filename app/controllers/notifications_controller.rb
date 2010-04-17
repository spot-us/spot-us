class NotificationsController < ApplicationController
  
  def index
    #nothing here if you have the wrong hash to pass in here :-)
    unless params[:code] && params[:code]==APP_CONFIG[:cron_job_code]
      head(:bad_request)
      render :text=>"Ooops, something doesn't exist there."
      return
    end
    notify_pitch_owners if params[:notification]=='pitch_owners'
    notify_pitch_owners if params[:notification]=='unpaid_donations'
    render :text=>"ok!" 
  end
  
  private
  
  def notify_pitch_owners
    posts = Post.find(:all, :conditions=> "created_at>='#{1.week.ago}'" ).map(&:pitch_id).uniq
    Pitch.unfunded.find(:all, :conditions => "id not in (#{posts.join(',')})").each do |pitch|
      Mailer.deliver_create_blog_post_notification(pitch)
    end
    return
  end
  
  def notify_unpaid_donations
    Donation.unpaid.all({:conditions=>["donations.created_at>?", 3.weeks.ago]}).map(&:user).uniq.each do |user|
      Mailer.deliver_unpaid_donations(user)
    end
    return
  end
  
end
