class AddPaypalTransactionIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :paypal_transaction_id, :string
  end

  def self.down
    remove_column :purchases, :paypal_transaction_id
  end
end
