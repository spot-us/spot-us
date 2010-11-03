class CreateNotificationEmails < ActiveRecord::Migration
  def self.up
    create_table :notification_emails do |t|
      t.string :subject
      t.text :body
      t.integer :status, :length=>2, :default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_emails
  end
end
