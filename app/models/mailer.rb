class Mailer < ActionMailer::Base
  def signup_notification(user)
    body :user => user
  end

  def password_reset_notification(user)
    recipients user.email
    from       '"spot.us" <donotreply@spot.us>'
    subject    "Password Reset"
    body       :user => user
  end
end
