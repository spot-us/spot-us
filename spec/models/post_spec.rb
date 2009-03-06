require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  requires_presence_of Post, :user
  requires_presence_of Post, :pitch
  requires_presence_of Post, :title
  requires_presence_of Post, :body

  it "should belong to a pitch" do
    Post.reflect_on_all_associations(:belongs_to).select{|a| a.name == :pitch}.should_not be_empty
  end

  it "should belong to a user" do
    Post.reflect_on_all_associations(:belongs_to).select{|a| a.name == :user}.should_not be_empty
  end
end
