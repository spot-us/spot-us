class CreateClickstreamArchives < ActiveRecord::Migration
  def self.up
    create_table :clickstream_archives do |t|
      t.string   "ip"
      t.string   "user_agent"
      t.string   "url"
      t.string   "referer"
      t.string   "session_id"
      t.integer  "user_id"
      t.string   "clickstreamable_type"
      t.integer  "clickstreamable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status",               :default => 0
    end
    
    add_index "clickstreams", ["session_id", "created_at"], :name => "clickstream_session_id_created_at_index"
  end

  def self.down
    drop_table :clickstream_archives
  end
end
