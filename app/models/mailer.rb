class Mailer < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = DEFAULT_HOST

  def activation_email(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    %(Welcome to Spot.Us – Please verify your email address")
    body :user => user
  end

  def citizen_signup_notification(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    %(Welcome to Spot.Us – "Community Funded Reporting")
    body :user => user
  end

  def reporter_signup_notification(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Welcome to Spot.Us – Reporting on Communities"
    body :user => user
  end

  def organization_signup_notification(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Important Information on Joining"
    body :user => user
  end

  def news_org_signup_request(user)
    recipients '"David Cohn" <david@spot.us>'
    from       MAIL_FROM_INFO
    subject    "Spot.Us: News Org Requesting to Join"
    body        :user => user
  end

  def password_reset_notification(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Password Reset"
    body       :user => user
  end

  def pitch_created_notification(pitch)
    recipients '"David Cohn" <david@spot.us>'
    from       MAIL_FROM_INFO
    subject    "Spot.Us: A pitch needs approval!"
    body       :pitch => pitch
  end

  def pitch_approved_notification(pitch)
    recipients pitch.user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Your pitch has been approved!"
    body       :pitch => pitch
  end

  def pitch_edited_notification(pitch)
    recipients MAIL_WEBMASTER
    from       MAIL_WEBMASTER
    subject    "Spot.Us: A pitch has been edited!"
    body       :pitch => pitch
  end

  def pitch_accepted_notification(pitch)
    recipients '"David Cohn" <david@spot.us>'
    bcc pitch.supporters.map(&:email).concat(Admin.all.map(&:email)).concat(pitch.subscribers.map(&:email)).uniq.join(', ')
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Success!! Your Story is Funded!"
    body       :pitch => pitch
  end
  
  def blog_posted_notification(post)
    recipients '"David Cohn" <david@spot.us>'
    bcc post.pitch.blog_subscribers.map(&:email).concat(Admin.all.map(&:email)).concat(post.pitch.subscribers.map(&:email)).uniq.join(', ')
    from       MAIL_FROM_INFO
    subject    "Spot.Us Blog Update: '#{post.pitch.headline}'"
    body       :post => post
  end
  
  def comment_notification(comment)
    recipients '"David Cohn" <david@spot.us>'
    bcc (comment.commentable.comment_subscribers - [comment.user]).map(&:email).join(", ")
    from       MAIL_FROM_INFO
    subject    "Spot.Us Blog Update: '#{comment.commentable.headline}'"
    body       :comment => comment
  end
  
  def story_to_editor_notification(story,send_to)
    recipients send_to
    from       MAIL_FROM_INFO
    subject    "Spot.Us Story Review: '#{story.headline}'"
    body       :story => story
  end
  
  def story_rejected_notification(story)
    recipients story.pitch.user.email
    bcc        '"David Cohn" <david@spot.us>'
    from       MAIL_FROM_INFO
    subject    "Spot.Us Story Requires Further Edits: '#{story.headline}'"
    body       :story => story
  end
  
  def story_published_notification(story, send_to)
    recipients send_to
    bcc story.pitch.supporters.map(&:email).concat(Admin.all.map(&:email)).concat(story.pitch.subscribers.map(&:email)).uniq.join(', ')
    from       MAIL_FROM_INFO
    subject    "Spot.Us Story Published: '#{story.headline}'"
    body       :story => story
  end

  # def admin_reporting_team_notification(pitch)
  #   recipients '"David Cohn" <david@spot.us>'
  #   from       MAIL_FROM_INFO
  #   subject    "Spot.Us: Someone wants to join a pitch's reporting team!"
  #   body       :pitch => pitch
  # end

  def reporter_reporting_team_notification(pitch)
    recipients pitch.user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Someone wants to join your reporting team!"
    body       :pitch => pitch
  end

  # def approved_reporting_team_notification(pitch, user)
  #   recipients user.email
  #   from       MAIL_FROM_INFO
  #   subject    "Spot.Us: Welcome to the reporting team!"
  #   body       :pitch => pitch
  # end

  # def applied_reporting_team_notification(pitch, user)
  #   recipients user.email
  #   from       MAIL_FROM_INFO
  #   subject    "Spot.Us: We received your application!"
  #   body       :pitch => pitch
  # end
  
  def assignment_application_notification(mail)
    recipients [mail[:assignment].user.email,mail[:contributor].email].join(",")
    bcc        '"David Cohn" <david@spot.us>'
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Assignment assignment application: " + mail[:assignment].pitch.headline
    body       mail
  end
  
  def assignment_application_accepted_notification(assignment, user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Assignment application accepted!"
    body       :assignment => assignment
  end
  
  def assignment_application_rejected_notification(assignment, user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Assignment application rejected!"
    body       :assignment => assignment
  end

  def story_ready_notification(story)
    recipients '"David Cohn" <david@spot.us>'
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Story ready for publishing"
    body       :story => story
  end

  def organization_approved_notification(user)
    recipients user.email
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Important Information on Joining"
    body       :user => user
  end

  def user_thank_you_for_donating(donation)
    recipients  donation.user.email
    from        MAIL_FROM_INFO
    subject     "Spot.Us: Thank You for Donating!"
    body        :donation => donation
  end
  
  def confirm_subscription(subscriber)
    recipients  subscriber.email
    from        MAIL_FROM_INFO
    subject     "Spot.Us: Subscription to '#{subscriber.pitch.headline}' confirmation required"
    body        :subscriber => subscriber
  end
end
