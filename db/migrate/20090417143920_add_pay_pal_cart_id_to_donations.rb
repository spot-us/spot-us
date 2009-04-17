class AddPayPalCartIdToDonations < ActiveRecord::Migration
  def self.up
    add_column :donations, :paypal_cart_id, :integer
  end

  def self.down
    remove_column :donations, :paypal_cart_id
  end
end
