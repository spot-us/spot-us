class AddAccessTokenToTwitterCredentials < ActiveRecord::Migration
  def self.up
	add_column :twitter_credentials, :access_token, :text
  end

  def self.down
	remove_column :twitter_credentials, :access_token
  end
end
