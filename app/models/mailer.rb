class Mailer < ActionMailer::Base
  def signup_notification(user)
    body :user => user
  end
end
