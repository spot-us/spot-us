class CreatePaypalTransactions < ActiveRecord::Migration
  def self.up
    create_table :paypal_transactions do |t|
      t.string :txn_id
      t.integer :purchase_id
      t.string :status
      t.text :paypal_response

      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_transactions
  end
end
