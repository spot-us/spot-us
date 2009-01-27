class Story < NewsItem
  aasm_initial_state  :draft

  aasm_state :draft
  aasm_state :fact_check
  aasm_state :ready
  aasm_state :published

  aasm_event :verify do
    transitions :from => :draft, :to => :fact_check
  end

  aasm_event :reject do
    transitions :from => :fact_check, :to => :draft
  end

  aasm_event :accept do
    transitions :from => :fact_check, :to => :ready, :on_transition=> :notify_admin
  end

  aasm_event :publish do
    transitions :from => :ready, :to => :published
  end

  belongs_to :pitch, :foreign_key => 'news_item_id'
  validate_on_update :extended_description

  named_scope :published, :conditions => {:status => 'published'}

  def editable_by?(user)
    return false if user.nil?
    return false if self.fact_checker == user
    if user.is_a?(Reporter)
      return (user == self.user) if self.draft?
    end
    return false if user.is_a?(Citizen)
    return true if user.is_a?(Admin)
    false
  end

  def viewable_by?(user)
    return true if user.is_a?(Admin)
    return true if self.published?
    if user.is_a?(Reporter)
      return reporter_view_permissions(user)
    end
    false
  end

  def publishable_by?(user)
    return false if user.nil?
    self.ready? && user.is_a?(Admin)
  end

  def reporter_view_permissions(user)
    return true if (user == self.user || self.fact_checker == user)
  end

  def fact_checkable_by?(user)
    return true if user.is_a?(Admin)
    user == self.fact_checker
  end

  def notify_admin
    Mailer.deliver_story_ready_notification(self)
  end
end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: news_items
#
#  id                          :integer(4)      not null, primary key
#  headline                    :string(255)
#  location                    :string(255)
#  state                       :string(255)
#  short_description           :text
#  delivery_description        :text
#  extended_description        :text
#  skills                      :text
#  keywords                    :string(255)
#  deliver_text                :boolean(1)      not null
#  deliver_audio               :boolean(1)      not null
#  deliver_video               :boolean(1)      not null
#  deliver_photo               :boolean(1)      not null
#  contract_agreement          :boolean(1)      not null
#  expiration_date             :datetime
#  created_at                  :datetime
#  updated_at                  :datetime
#  featured_image_file_name    :string(255)
#  featured_image_content_type :string(255)
#  featured_image_file_size    :integer(4)
#  featured_image_updated_at   :datetime
#  type                        :string(255)
#  video_embed                 :text
#  featured_image_caption      :string(255)
#  user_id                     :integer(4)
#  requested_amount_in_cents   :integer(4)
#  current_funding_in_cents    :integer(4)      default(0)
#  status                      :string(255)
#  feature                     :boolean(1)
#  fact_checker_id             :integer(4)
#  news_item_id                :integer(4)
#  deleted_at                  :datetime
#  widget_embed                :text
#

