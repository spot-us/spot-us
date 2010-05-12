class Add < ActiveRecord::Migration
  def self.up
    add_column :credits, :is_cca_credit, :boolean, :default => false
  end

  def self.down
    remove_column :credits, :is_cca_credit
  end
end