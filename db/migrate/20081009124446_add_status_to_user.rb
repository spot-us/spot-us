class AddStatusToUser < ActiveRecord::Migration
  def self.up
    add_column  :users, :status, :string, :default => 'active'
  end

  def self.down
    remove_column :users, :status
  end
end
