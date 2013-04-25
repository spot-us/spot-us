class Mailer < ActionMailer::Base
  include ActionController::UrlWriter
  helper :application
  include ApplicationHelper
  default_url_options[:host] = DEFAULT_HOST

  def notification_email(to, subject, message)
    recipients to
    from       get_email(:info)
    subject    subject
    body :message => message
  end

  def activation_email(user)
    recipients user.email
    from       get_email(:info)
    subject    %(Welcome to Spot.Us – Please verify your email address")
    body :user => user
  end

  def citizen_signup_notification(user)
    recipients user.email
    from       get_email(:info)
    subject    %(Welcome to Spot.Us – "Community Funded Reporting")
    body :user => user
  end

  def reporter_signup_notification(user)
    recipients user.email
    from       get_email(:info)
    subject    "Welcome to Spot.Us – Reporting on Communities"
    body :user => user
  end
  
  def sponsor_interest_notification(user)
    recipients get_email(:info)
    from       get_email(:info)
    subject    "Spot.Us - Someone has signed up to a Sponsor"
    body :user => user
  end

  def organization_signup_notification(user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Important Information on Joining"
    body :user => user
  end

  def news_org_signup_request(user)
    recipients get_email(:admin)
    from       get_email(:info)
    subject    "Spot.Us: News Org Requesting to Join"
    body        :user => user
  end

  def password_reset_notification(user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Password Reset"
    body       :user => user
  end

  def pitch_created_notification(pitch)
    recipients get_email(:pitch)
    from       get_email(:info)
    subject    "Spot.Us: A pitch needs approval!"
    body       :pitch => pitch
  end

  def pitch_approved_notification(pitch)
    recipients pitch.user.email
    from       get_email(:info)
    subject    "Spot.Us: Your pitch has been approved!"
    body       :pitch => pitch
  end

  def pitch_edited_notification(pitch)
    recipients get_email(:webmaster)
    from       get_email(:webmaster)
    subject    "Spot.Us: A pitch has been edited!"
    body       :pitch => pitch
  end

  def pitch_accepted_notification(pitch,to,email,subscriber=nil)
    recipients  email
    from       get_email(:info)
    subject    "Spot.Us: Success!! Your Story is Funded!"
    body       :pitch => pitch, :to => to, :email => email, :subscriber=>subscriber
  end
  
  def blog_posted_notification(post,to,email,subscriber=nil)
    recipients  email
    from       get_email(:info)
    subject    "Spot.Us Blog Update: '#{post.pitch.headline}'"
    body       :post => post, :to => to, :email => email, :subscriber=>subscriber
  end
  
  def comment_notification(comment, user)
    recipients  user.email
    from       get_email(:info)
    subject    "Spot.Us Comment: '#{comment.commentable.headline}'"
    body       :comment => comment, :user => user
  end
  
  def story_to_editor_notification(story,to,email)
    recipients email
    from       get_email(:info)
    subject    "Spot.Us Story Review: '#{story.headline}'"
    body       :story => story, :to => to, :email => email
  end
  
  def story_rejected_notification(story)
    recipients story.pitch.user.email
    bcc        get_email(:admin)
    from       get_email(:info)
    subject    "Spot.Us Story Requires Further Edits: '#{story.headline}'"
    body       :story => story
  end
  
  def story_published_notification(story,to,email,subscriber=nil)
    recipients  email
    from       get_email(:info)
    subject    "Spot.Us Story Published: '#{story.headline}'"
    body       :story => story, :to => to, :email => email, :subscriber=>subscriber
  end

  def admin_reporting_team_notification(pitch)
    recipients get_email(:admin)
    from       get_email(:info)
    subject    "Spot.Us: Someone wants to join a pitch's reporting team!"
    body       :pitch => pitch
  end

  def reporter_reporting_team_notification(pitch)
    recipients pitch.user.email
    from       get_email(:info)
    subject    "Spot.Us: Someone wants to join your reporting team!"
    body       :pitch => pitch
  end

  def create_blog_post_notification(pitch)
    recipients pitch.user.email
    from       get_email(:info)
    subject    "Spot.Us: Create a blog post, build community and interest around the post!"
    body       :pitch => pitch
  end
  
  def unpaid_donations(user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: You have unpaid donations!"
    body       :user => user
  end
  
  def approved_reporting_team_notification(pitch, user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Welcome to the reporting team!"
    body       :pitch => pitch, :user => user
  end

  def applied_reporting_team_notification(pitch, user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: We received your application!"
    body       :pitch => pitch, :user => user
  end
  
  def assignment_application_notification(mail)
    recipients mail[:assignment].user.email
    bcc        get_email(:admin)
    from       get_email(:info)
    subject    "Spot.Us: Assignment assignment application: " + mail[:assignment].pitch.slug?
    body       mail
  end
  
  def assignment_application_accepted_notification(assignment, user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Assignment application accepted!"
    body       :assignment => assignment, :user => user
  end
  
  def assignment_application_rejected_notification(assignment, user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Assignment application rejected!"
    body       :assignment => assignment, :user => user
  end

  def story_ready_notification(story)
    recipients get_email(:admin)
    from       get_email(:info)
    subject    "Spot.Us: Story ready for publishing"
    body       :story => story
  end

  def organization_approved_notification(user)
    recipients user.email
    from       get_email(:info)
    subject    "Spot.Us: Important Information on Joining"
    body       :user => user
  end

  def user_thank_you_for_donating(donation)
    recipients  donation.user.email
    from        get_email(:info)
    subject     "Spot.Us: Thank You for Donating!"
    body        :donation => donation, :user => donation.user
  end
  
  def confirm_subscription(subscriber)
    recipients  subscriber.email
    from        get_email(:info)
    subject     "Spot.Us: Subscription to '#{subscriber.pitch.headline}' confirmation required"
    body        :subscriber => subscriber
  end
  
  def notification_mass_email(ne, user)
    recipients  user.email
    from        get_email(:info)
    subject     ne.subject
    body        :ne => ne, :user => user
  end
  
  def thank_you_for_your_pitch(user, pitch)
    recipients  user.email
    from        get_email(:info)
    subject     "Thanks for creating a pitch on Spot.Us!"
    body        :pitch => pitch, :user => user
  end
  
  def sponsor_signup_email(sponsor)
    recipients  get_email(:info)
    from        get_email(:info)
    subject     "A new sponsor has signed up!"
    body        :sponsor => sponsor
  end
  
  def reporting(start_date, end_date, interval, has_donations=true)
    recipients  APP_CONFIG[:reporting][:emails]
    from        get_email(:info)
    subject     "SPOT.US: #{interval.capitalize} Report for donations between #{start_date.strftime("%m/%d/%y")}-#{end_date.strftime("%m/%d/%y")}"
    content_type  "multipart/mixed"

    part "text/html" do |p|
      p.body = render_message 'reporting', {:start_date => start_date, :end_date => end_date, :interval => interval, :has_donations => has_donations}
    end
    
    if has_donations
      attachment  :content_type => 'text/plain', :filename => ["donation",interval,"report",start_date.strftime("%m-%d-%y"),end_date.strftime("%m-%d-%y")].join("_")+".csv", :body => File.read(APP_CONFIG[:reporting][:file])
    end
  end
  
end
