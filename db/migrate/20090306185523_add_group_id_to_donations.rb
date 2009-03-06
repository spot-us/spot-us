class AddGroupIdToDonations < ActiveRecord::Migration
  def self.up
    add_column :donations, :group_id, :integer
  end

  def self.down
    remove_column :donations, :group_id
  end
end
