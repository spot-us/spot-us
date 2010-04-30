class ChangeColumnNameTwitterCredentials < ActiveRecord::Migration
  def self.up
    rename_column :twitter_credentials, :user_name, :login 
  end

  def self.down
    rename_column :twitter_credentials, :login, :user_name 
  end
end
