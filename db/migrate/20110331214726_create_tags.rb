class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string        :tag
      t.integer       :tag_count
      t.integer       :normalized_tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tags
  end
end
