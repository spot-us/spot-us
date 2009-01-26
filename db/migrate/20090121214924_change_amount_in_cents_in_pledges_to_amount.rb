class TempPledge < ActiveRecord::Base
  set_table_name :pledges
end

class ChangeAmountInCentsInPledgesToAmount < ActiveRecord::Migration
  def self.up
    add_column :pledges, :amount, :decimal, :precision => 15, :scale => 2
    TempPledge.update_all('amount = amount_in_cents / 100')
    remove_column :pledges, :amount_in_cents
  end

  def self.down
    add_column :pledges, :amount_in_cents, :integer
    TempPledge.update_all('amount_in_cents = amount * 100')
    remove_column :pledges, :amount
  end
end

