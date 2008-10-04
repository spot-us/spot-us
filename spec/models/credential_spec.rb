require File.dirname(__FILE__) + '/../spec_helper'

describe Credential do
  table_has_columns(Credential, :string, "title")
  table_has_columns(Credential, :string, "url")
  table_has_columns(Credential, :text, "description")
  requires_presence_of Credential, :user_id
  it { Credential.should belong_to(:user) }
  
  describe "to support STI" do
    table_has_columns(Credential, :string, :type)
  end
end
