class AddStatusToCreditPitches < ActiveRecord::Migration
  def self.up
      add_column :credit_pitches, :status, :string, :default => "unpaid"
      add_column :credit_pitches, :paid_credit_id, :integer
  end

  def self.down
      remove_column :credit_pitches, :status
      remove_column :credit_pitches, :paid_credit_id
  end
end
