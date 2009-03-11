require File.dirname(__FILE__) + '/../spec_helper'

describe Mailer do
  it "sends an activation email on deliver_activation_email" do
    user = Factory(:citizen)
    lambda do
      Mailer.deliver_activation_email(user)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on deliver_citizen_signup_notification" do
    user = Factory(:user)
    user.activate!
    lambda do
      Mailer.deliver_citizen_signup_notification(user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on deliver_reporter_signup_notification" do
    user = Factory(:reporter)
    lambda do
      Mailer.deliver_reporter_signup_notification(user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on deliver_organization_signup_notification" do
    user = Factory(:organization)
    lambda do
      Mailer.deliver_organization_signup_notification(user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends a multipart email on delivery" do
    user = Factory(:user)
    Mailer.deliver_citizen_signup_notification(user)
    mail = ActionMailer::Base.deliveries.first
    mail.content_type.should == "multipart/alternative"
  end

  it "sends an email on password_reset_notification" do
    user = stub_model(User)
    lambda do
      Mailer.deliver_password_reset_notification(user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on pitch creation" do
    pitch = stub_model(Pitch)
    lambda do
      Mailer.deliver_pitch_created_notification(pitch)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email to David when someone wants to join a pitch's reporting team" do
    pitch = stub_model(Pitch)
    lambda do
      Mailer.deliver_admin_reporting_team_notification(pitch)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end
  it "sends an email to the pitch's reporter when someone wants to join a pitch's reporting team" do
    pitch = stub_model(Pitch, :user => stub_model(Reporter))
    lambda do
      Mailer.deliver_reporter_reporting_team_notification(pitch)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end
  it "sends an email to the user after applying to blog" do
    pitch = stub_model(Pitch, :user => stub_model(Reporter))
    lambda do
      Mailer.deliver_applied_reporting_team_notification(pitch, stub_model(User, :email => "someone@example.com"))
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end
  it "sends an email to the user when approved to blog" do
    pitch = stub_model(Pitch, :user => stub_model(Reporter))
    lambda do
      Mailer.deliver_approved_reporting_team_notification(pitch, stub_model(User, :email => "someone@example.com"))
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on pitch accepted" do
    pitch = stub_model(Pitch)
    lambda do
      Mailer.deliver_pitch_accepted_notification(pitch)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on pitch approved" do
    pitch = active_pitch
    lambda do
      Mailer.deliver_pitch_approved_notification(pitch)
    end.should change {ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email on story accepted" do
    story = stub_model(Pitch)
    lambda do
      Mailer.deliver_story_ready_notification(story)
    end.should change {ActionMailer::Base.deliveries.size}.by(1)
  end

  it "sends an email to news org when approved" do
    user = stub_model(User, :activation_code => 17)
    lambda do
      Mailer.deliver_organization_approved_notification(user)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "sends an email to user when they donate" do
    user = Factory(:user)
    donation = Factory(:donation, :user => user)
    lambda do
      Mailer.deliver_user_thank_you_for_donating(donation)
    end.should change { ActionMailer::Base.deliveries.size }.by(1)
  end

end
