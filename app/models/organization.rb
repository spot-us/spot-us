# == Schema Information
# Schema version: 20090218144012
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  first_name                :string(255)
#  last_name                 :string(255)
#  type                      :string(255)
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer(4)
#  location                  :string(255)
#  about_you                 :text
#  website                   :string(255)
#  address1                  :string(255)
#  address2                  :string(255)
#  city                      :string(255)
#  state                     :string(255)
#  zip                       :string(255)
#  phone                     :string(255)
#  country                   :string(255)
#  notify_tips               :boolean(1)      not null
#  notify_pitches            :boolean(1)      not null
#  notify_stories            :boolean(1)      not null
#  notify_spotus_news        :boolean(1)      not null
#  fact_check_interest       :boolean(1)      not null
#  status                    :string(255)
#  organization_name         :string(255)
#  established_year          :string(255)
#  deleted_at                :datetime
#  activation_code           :string(255)
#

class Organization < User
  before_validation_on_create :set_status
  after_create :deliver_signup_notification

  has_many :organization_pitches, :foreign_key => :organization_id
  has_many :supported_pitches, :through => :organization_pitches, :source => :pitch

  aasm_state :needs_approval
  aasm_state :approved

  aasm_event :needs_to_be_approved do
    transitions :from => :inactive, :to => :needs_approval
  end

  aasm_event :approve do
    transitions :from => :needs_approval, :to => :approved,
                :on_transition => :do_after_approved_actions
  end

  def deliver_signup_notification
    Mailer.deliver_organization_signup_notification(self)
    Mailer.deliver_news_org_signup_request(self)
  end

  def do_after_approved_actions
    Mailer.deliver_organization_approved_notification(self)
  end

  def set_status
    needs_to_be_approved! if inactive?
  end

  def show_support_for(pitch)
    pitch.supporting_organizations << self
  end

  def shown_support_for?(pitch)
    pitch.supporting_organizations.include? self
  end
end

