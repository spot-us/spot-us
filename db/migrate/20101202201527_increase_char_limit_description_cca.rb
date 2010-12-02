class IncreaseCharLimitDescriptionCca < ActiveRecord::Migration
  def self.up
    change_column :ccas, :description, :string, :limit => 1028
  end

  def self.down
    change_column :ccas, :description, :string, :limit => 500
  end
end
