class AddHelpSections < ActiveRecord::Migration

  def self.up
    create_table :sections do |t|
      t.string :title, :name
      t.text :short_description, :extended_description, :embed_code
      t.timestamps
    end
    add_index :sections, :name
  end

  def self.down
    drop_table :sections
  end

end