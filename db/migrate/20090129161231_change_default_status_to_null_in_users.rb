class ChangeDefaultStatusToNullInUsers < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE users ALTER COLUMN status DROP DEFAULT'
  end

  def self.down
    change_column_default :users, :status, "active"
  end
end
