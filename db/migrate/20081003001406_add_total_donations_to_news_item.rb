class AddTotalDonationsToNewsItem < ActiveRecord::Migration
  def self.up
    change_table :news_items do |t|
      t.integer :current_funding_in_cents, :default => 0
    end
  end

  def self.down
    change_table :news_items do |t|
      t.remove :current_funding_in_cents
    end
  end
end
