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
    recipients '"David Cohn" <david@spotus.com>'
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

  def pitch_accepted_notification(pitch)
    recipients '"David Cohn" <david@spotus.com>'
    bcc pitch.supporters.map(&:email).concat(Admin.all.map(&:email)).join(', ')
    from       MAIL_FROM_INFO
    subject    "Spot.Us: Success!! Your Story is Funded!"
    body       :pitch => pitch
  end

  def story_ready_notification(story)
    recipients '"David Cohn" <david@spotus.com>'
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
end
