class Post < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user

  validates_presence_of :title, :body, :user, :pitch
  
  def blog_posted_notification
    Mailer.deliver_blog_posted_notification(self)
  end
  
  named_scope :by_network, lambda {|network|
    return {} unless network
    {:conditions =>  ["pitch_id in (select id from news_items where network_id in (select id from networks where id = ?))", network]}
    }
    named_scope :latest, :order => "posts.id desc", :limit => 3
end
