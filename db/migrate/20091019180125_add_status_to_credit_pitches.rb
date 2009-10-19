class AddStatusToCreditPitches < ActiveRecord::Migration
  def self.up
      add_column :credit_pitches, :status, :string, :default => "unpaid"
  end

  def self.down
      remove_column :credit_pitches, :status
  end
end
