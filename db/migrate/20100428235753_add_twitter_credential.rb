class AddTwitterCredential < ActiveRecord::Migration
  def self.up
    create_table "twitter_credentials", :force => true do |t|
      t.integer   :user_id
      t.string    :user_name
      t.string    :password
      t.datetime  :created_at,:updated_at
    end
  end

  def self.down
    drop_table 'twitter_credentials'
  end
end
