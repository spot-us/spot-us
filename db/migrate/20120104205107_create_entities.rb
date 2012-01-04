class CreateEntities < ActiveRecord::Migration
  def self.up
    create_table :entities do |t|
      t.string        :entitable_type
      t.integer       :entitable_id
      t.text          :request_body
      t.timestamps
    end
  end

  def self.down
    drop_table :entities
  end
end
