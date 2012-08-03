class NotificationsController < ApplicationController
  
  def index
    #nothing here if you have the wrong hash to pass in here :-)
    unless params[:code] && params[:code]==APP_CONFIG[:cron_job_code]
      head(:bad_request)
      render :text=>"Ooops, something doesn't exist there."
      return
    end
    notify_pitch_owners if params[:notification]=='pitch_owners'
    send_notification_emails if params[:notification]=='send_notification_emails'
    render :text=>"ok!" 
  end
  
  def social_notify
     Mailer.deliver_notification_email(params[:email_list],params[:subject],params[:message]) 
     render :text => "email has been sent."
  end
  
  private
  
  def notify_pitch_owners
    posts = Post.find(:all, :conditions=> "created_at>='#{1.week.ago}'" ).map(&:pitch_id).uniq
    Pitch.unfunded_with_no_story.find(:all, :conditions => "id not in (#{posts.join(',')}) and expiration_date>NOW()").each do |pitch|
      Mailer.deliver_create_blog_post_notification(pitch)
    end
    return
  end
  
  def send_notification_emails
    NotificationEmail.to_send.all.each do |ne|
      ne.update_attributes({ :status => 2 })
      users = ne.users?
      if users && !users.empty?
        users.compact.each do |user|
          Mailer.deliver_notification_mass_email(ne, user) if user
        end
        conditions = "email not in (#{users.compact.map{ |u| "'#{u.email}'"}.join(',')})"
        Admin.find(:all,:conditions => conditions).compact.each do |admin|
          Mailer.deliver_notification_mass_email(ne, admin) if admin
        end 
      end
    end
    return
  end
  
end
