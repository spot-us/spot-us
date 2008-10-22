class DropPaidColumnFromDonations < ActiveRecord::Migration
  def self.up
    remove_column :donations, :paid
  end

  def self.down
    add_column :donations, :paid, :default => false, :null => false
  end
end
