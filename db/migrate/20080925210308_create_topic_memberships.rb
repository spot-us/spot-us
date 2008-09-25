class CreateTopicMemberships < ActiveRecord::Migration
  def self.up
    create_table :topic_memberships do |t|
      t.integer :member_id
      t.string  :member_type 
      t.integer :topic_id
      t.timestamps
    end
  end

  def self.down
    drop_table :topic_memberships
  end
end
