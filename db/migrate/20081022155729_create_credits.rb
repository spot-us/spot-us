class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.belongs_to :user
      t.string  :description
      t.integer :amount_in_cents
      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
