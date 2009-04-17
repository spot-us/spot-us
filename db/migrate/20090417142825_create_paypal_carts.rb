class CreatePaypalCarts < ActiveRecord::Migration
  def self.up
    create_table :paypal_carts do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_carts
  end
end
