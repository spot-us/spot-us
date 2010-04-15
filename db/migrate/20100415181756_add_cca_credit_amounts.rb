class AddCcaCreditAmounts < ActiveRecord::Migration
  def self.up
    add_column :ccas, :max_credits_amount, :decimal, :precision => 15, :scale => 2, :default => 0
    add_column :ccas, :credits_awarded, :decimal, :precision => 15, :scale => 2, :default => 0
    add_column :ccas, :award_amount, :decimal, :precision => 15, :scale => 2, :default => 0
  end

  def self.down
    remove_column :ccas, :max_credit_amount
    remove_column :ccas, :credits_awarded
    remove_column :ccas, :award_amount
  end
end
