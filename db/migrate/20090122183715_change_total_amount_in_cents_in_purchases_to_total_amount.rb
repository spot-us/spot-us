class TempPurchase < ActiveRecord::Base
  set_table_name :purchases
end

class ChangeTotalAmountInCentsInPurchasesToTotalAmount < ActiveRecord::Migration
  def self.up
    add_column :purchases, :total_amount, :decimal, :precision => 15, :scale => 2
    TempPurchase.update_all('total_amount = total_amount_in_cents / 100')
    remove_column :purchases, :total_amount_in_cents
  end

  def self.down
    add_column :purchases, :total_amount_in_cents, :integer
    TempPurchase.update_all('total_amount_in_cents = total_amount * 100')
    remove_column :purchases, :total_amount
  end
end
