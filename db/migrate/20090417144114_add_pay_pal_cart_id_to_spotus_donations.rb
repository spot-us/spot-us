class AddPayPalCartIdToSpotusDonations < ActiveRecord::Migration
  def self.up
    add_column :spotus_donations, :paypal_cart_id, :integer
  end

  def self.down
    remove_column :spotus_donations, :paypal_cart_id
  end
end
