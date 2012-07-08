class AddBannedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_banned, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_banned
  end
end
