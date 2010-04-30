class AddSettingsColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_facebook_wall, :boolean, :default => true, :after => :notify_comments
    add_column :users, :notify_twitter, :boolean, :default => true, :after => :notify_facebook_wall
    User.update_all("notify_facebook_wall = 1, notify_twitter = 1")
  end

  def self.down
    remove_column :users, :notify_facebook_wall
    remove_column :users, :notify_facebook_twitter
  end
end