class TempDonation < ActiveRecord::Base
  set_table_name :donations
end

class ChangeAmountInCentsInDonationsToAmount < ActiveRecord::Migration
  def self.up
    add_column :donations, :amount, :decimal, :precision => 15, :scale => 2
    TempDonation.update_all('amount = amount_in_cents / 100')
    remove_column :donations, :amount_in_cents
  end

  def self.down
    add_column :donations, :amount_in_cents, :integer
    TempDonation.update_all('amount_in_cents = amount * 100')
    remove_column :donations, :amount
  end
end

