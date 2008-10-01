class ChangeRequestedAmountOnPitch < ActiveRecord::Migration
  def self.up
    remove_column :news_items, :requested_amount
    add_column :news_items, :requested_amount_in_cents, :integer
  end

  def self.down
    add_column :news_items, :requested_amount, :integer
    remove_column :news_items, :requested_amount_in_cents
  end
end
