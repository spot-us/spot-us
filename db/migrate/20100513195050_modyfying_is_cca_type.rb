class ModyfyingIsCcaType < ActiveRecord::Migration
  def self.up
    remove_column :credits, :is_cca_credit
    add_column :credits, :cca_id, :integer
  end

  def self.down
    remove_column :credits, :cca_id
    add_column :credits, :is_cca_credit, :boolean, :default => false
  end
end
