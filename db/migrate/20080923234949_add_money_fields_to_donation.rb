class AddMoneyFieldsToDonation < ActiveRecord::Migration
  def self.up
    change_table :donations do |t|
      t.integer :amount_in_cents
      t.boolean :paid, :default => nil, :null => true
    end
  end

  def self.down
    change_table :donations do |t|
      t.remove :amount_in_cents, :paid
    end
  end
end

