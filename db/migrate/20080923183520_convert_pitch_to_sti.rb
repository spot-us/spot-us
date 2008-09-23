class ConvertPitchToSti < ActiveRecord::Migration
  def self.up
    change_table :pitches do |t|
      t.column :type, :string
    end
    rename_table :pitches, :news_items
    add_index :news_items, :type
  end

  def self.down
    change_table :news_items do |t|
      t.remove :type
    end
    remove_index :pitches, :type
    rename_table :news_items, :pitches
  end
end
