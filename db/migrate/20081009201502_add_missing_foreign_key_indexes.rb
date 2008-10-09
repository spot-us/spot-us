class AddMissingForeignKeyIndexes < ActiveRecord::Migration
  def self.up
    add_index :donations, :purchase_id
    add_index :purchases, :user_id
    add_index :topic_memberships, :member_id
    add_index :topic_memberships, :topic_id
  end

  def self.down
    remove_index :topic_memberships, :topic_id
    remove_index :topic_memberships, :member_id
    remove_index :purchases, :user_id
    remove_index :donations, :purchase_id
  end
end
