class TempPitch < ActiveRecord::Base
  set_table_name :news_items
end

class ChangeAmountInCentsInNewsItemsToAmount < ActiveRecord::Migration
  def self.up
    add_column :news_items, :requested_amount, :decimal, :precision => 15, :scale => 2
    add_column :news_items, :current_funding, :decimal, :precision => 15, :scale => 2
    TempPitch.update_all('requested_amount = requested_amount_in_cents / 100', "type = 'Pitch'")
    TempPitch.update_all('current_funding = current_funding_in_cents / 100', "type = 'Pitch'")
    remove_column :news_items, :requested_amount_in_cents
    remove_column :news_items, :current_funding_in_cents
  end

  def self.down
    add_column :news_items, :requested_amount_in_cents, :integer
    add_column :news_items, :current_funding_in_cents, :integer
    TempPitch.update_all('requested_amount_in_cents = requested_amount * 100', "type = 'Pitch'")
    TempPitch.update_all('current_funding_in_cents = current_funding * 100', "type = 'Pitch'")
    remove_column :news_items, :requested_amount
    remove_column :news_items, :current_funding
  end
end

