class CreateGroupingsUsers < ActiveRecord::Migration
  def self.up
    create_table :groupings_users do |t|
      t.integer     :grouping_id, :user_id
      t.timestamps
    end
    remove_column :groupings_users, :id
  end

  def self.down
    drop_table :groupings_users
  end
end
