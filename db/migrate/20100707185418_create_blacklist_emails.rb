class CreateBlacklistEmails < ActiveRecord::Migration
  def self.up
    create_table :blacklist_emails do |t|
      t.string      :email
      t.timestamps
    end
  end

  def self.down
    drop_table :blacklist_emails
  end
end
