# == Schema Information
# Schema version: 20090218144012
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
#  status                      :string(255)
#  feature                     :boolean(1)
#  fact_checker_id             :integer(4)
#  news_item_id                :integer(4)
#  deleted_at                  :datetime
#  widget_embed                :text
#  requested_amount            :decimal(15, 2)
#  current_funding             :decimal(15, 2)
#

class Story < NewsItem
  # cleanse_columns(:extended_description) do |sanitizer|
  #   sanitizer.allowed_tags.add(%w(object param embed a img))
  #   sanitizer.allowed_attributes.add(%w(width height name src value allowFullScreen type href allowScriptAccess style wmode pluginspage classid codebase data quality))
  # end

  aasm_initial_state  :draft
  aasm_state :draft
  aasm_state :fact_check
  aasm_state :ready
  aasm_state :published

  aasm_event :verify do
    transitions :from => :draft, :to => :fact_check, :on_transition => :notify_editor
  end

  aasm_event :reject do
    transitions :from => :fact_check, :to => :draft, :on_transition => :notify_reporter
  end

  aasm_event :accept do
    transitions :from => [:fact_check,:draft], :to => :ready, :on_transition => :notify_admin
  end

  aasm_event :publish do
    transitions :from => :ready, :to => :published, :on_transition => :notify_donors
  end

  belongs_to :pitch, :foreign_key => 'news_item_id'
  
  has_many :organizational_donors, :through => :donations, :source => :user, :order => "donations.created_at", 
            :conditions => "users.type = 'organization'",
            :uniq => true
  validate_on_update :extended_description

  named_scope :latest, :order => "updated_at desc", :limit => 6
  def supporting_organizations
    pitch.supporting_organizations
  end
  
  def donations
    pitch.donations
  end
  
  def donating_groups
    pitch.donating_groups
  end
  
  def supporters
    pitch.supporters
  end
  
  def fact_checker
    self.peer_reviewer
  end
  
  def total_amount_donated
    pitch.total_amount_donated
  end

  def editable_by?(user)
    return false if user.nil?
    #return false if self.fact_checker == user
    return true if self.user == user and self.status == "draft"
    return true if self.fact_checker == user and self.status == "fact_check"
    # if user.is_a?(Reporter)
    #   return (user == self.user) if self.draft?
    # end
    return false if user.is_a?(Citizen)
    return true if user.is_a?(Admin)
    false
  end

  def viewable_by?(user)
    return true if user.is_a?(Admin)
    return true if self.published?
    return true if self.pitch.peer_reviewer == user
    return true if self.user == user
    # if user.is_a?(Reporter)
    #   return reporter_view_permissions(user)
    # end
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
  
  def notify_editor
    if self.pitch && self.pitch.fact_checker_id
        fact_checker = User.find_by_id(self.pitch.fact_checker_id)
        if fact_checker && fact_checker.email
            Mailer.deliver_story_to_editor_notification(self,fact_checker.full_name,fact_checker.email)
        end
    end
    Mailer.deliver_story_to_editor_notification(self,"David","david@spot.us")
  end
  
  def notify_reporter
    Mailer.deliver_story_rejected_notification(self)
  end
  
  def notify_donors
    self.pitch.touch_pitch!
    
    emails = BlacklistEmail.all.map{ |be| "'#{be.email}'"}
    conditions = ""
    
    #email supporters
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.pitch.supporters.find(:all,:conditions=>conditions).each do |supporter|
      Mailer.deliver_story_published_notification(self, supporter.first_name, supporter.email)
    end
    emails = emails.concat(self.pitch.supporters.map{ |s| "'#{s.email}'"})
    
    #email admins
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    Admin.find(:all,:conditions=>conditions).each do |admin|
      Mailer.deliver_story_published_notification(self, admin.first_name, admin.email)
    end
    emails = emails.concat(Admin.all.map{ |admin| "'#{admin.email}'"}).uniq
    
    #email subscribers
    conditions = "email not in (#{emails.join(',')})" if emails && !emails.empty?
    self.pitch.subscribers.find(:all,:conditions=>conditions).each do |subscriber|
      Mailer.deliver_story_published_notification(self, "Subscriber", subscriber.email, subscriber)
    end
    emails = emails.concat(self.pitch.subscribers.map{ |s| "'#{s.email}'"}).uniq
    
    #email fact checker if not already covered...
    if self.pitch && self.pitch.fact_checker_id
        fact_checker = User.find_by_id(self.pitch.fact_checker_id)
        if fact_checker && fact_checker.email && !emails.include?("'#{fact_checker.email}'")
            Mailer.deliver_story_published_notification(self,fact_checker.first_name,fact_checker.email)
        end
    end
    
    update_twitter
    update_facebook
  end
  
  protected
  def fact_checker_recipients
      recipients = '"David Cohn" <david@spot.us>'
      if self.pitch && self.pitch.fact_checker
          fact_checker = User.find_by_id(self.pitch.fact_checker.id)
          if fact_checker && fact_checker.email
              recipients += (", " + fact_checker.email)
          end
      end
      recipients
  end
end

