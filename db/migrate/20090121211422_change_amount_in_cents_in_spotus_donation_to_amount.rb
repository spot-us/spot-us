class TempSpotusDonation < ActiveRecord::Base
  set_table_name :spotus_donations
end

class ChangeAmountInCentsInSpotusDonationToAmount < ActiveRecord::Migration
  def self.up
    add_column :spotus_donations, :amount, :decimal, :precision => 15, :scale => 2
    TempSpotusDonation.update_all('amount = amount_in_cents / 100')
    remove_column :spotus_donations, :amount_in_cents
  end

  def self.down
    add_column :spotus_donations, :amount_in_cents, :integer
    TempSpotusDonation.update_all('amount_in_cents = amount * 100')
    remove_column :spotus_donations, :amount
  end
end
