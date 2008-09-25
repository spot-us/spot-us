class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :credit_card_number_ending
      t.string  :address1
      t.string  :address2
      t.string  :city
      t.string  :state
      t.string  :zip
      t.string  :phone
      t.integer :user_id
      t.integer :total_amount_in_cents
      t.timestamps
    end
    add_column :donations, :purchase_id, :integer
  end

  def self.down
    remove_column :donations, :purchase_id
    drop_table :purchases
  end
end
