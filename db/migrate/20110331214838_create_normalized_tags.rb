class CreateNormalizedTags < ActiveRecord::Migration
  def self.up
    create_table :normalized_tags do |t|
      t.string        :tag
      t.integer       :tag_count
      t.timestamps
    end
  end

  def self.down
    drop_table :normalized_tags
  end
end
