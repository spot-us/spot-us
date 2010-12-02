class CreateGroupings < ActiveRecord::Migration
  def self.up
    create_table :groupings do |t|
      t.string        :name, :seo_name
      t.text          :description
      t.timestamps
    end
  end

  def self.down
    drop_table :groupings
  end
end
