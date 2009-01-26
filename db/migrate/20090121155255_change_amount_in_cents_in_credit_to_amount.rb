class TempCredit < ActiveRecord::Base
  set_table_name :credits
end

class ChangeAmountInCentsInCreditToAmount < ActiveRecord::Migration
  def self.up
    add_column :credits, :amount, :decimal, :precision => 15, :scale => 2
    TempCredit.update_all('amount = amount_in_cents / 100')
    remove_column :credits, :amount_in_cents
  end

  def self.down
    add_column :credits, :amount_in_cents, :integer
    TempCredit.update_all('amount_in_cents = amount * 100')
    remove_column :credits, :amount
  end
end
