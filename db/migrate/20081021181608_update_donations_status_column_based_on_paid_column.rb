class UpdateDonationsStatusColumnBasedOnPaidColumn < ActiveRecord::Migration
  def self.up
    execute("update donations set status = 'paid' where paid = 1")
  end

  def self.down
    execute("update donations set paid = 1 where status = 'paid'")
    execute("update donations set paid = 0 where status = 'unpaid'")
  end
end
