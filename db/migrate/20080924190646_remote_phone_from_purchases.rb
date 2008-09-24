class RemotePhoneFromPurchases < ActiveRecord::Migration
  def self.up
    remove_column :purchases, :phone
  end

  def self.down
    add_column :purchases, :phone, :string
  end
end
