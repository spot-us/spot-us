class AddListIdToNotificationEmails < ActiveRecord::Migration
  def self.up
    add_column :notification_emails, :list_id, :integer, :size => 2, :default => 0
  end

  def self.down
    remove_column :notification_emails, :list_id
  end
end
