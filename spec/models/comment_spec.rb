require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  table_has_columns(Comment, :string,   "commentable_type")
  table_has_columns(Comment, :string,   "title")
  table_has_columns(Comment, :integer,  "commentable_id")
  table_has_columns(Comment, :integer,  "user_id")
  table_has_columns(Comment, :text,     "body")

  requires_presence_of Comment, :body
  requires_presence_of Comment, :title

  it { Factory(:comment).should belong_to(:commentable) }

  it "should not be valid if body length is greater than 2000" do
    comment = Factory(:comment)
    comment.body = 'f' * 2001
    comment.save
    comment.errors_on(:body).should_not be_nil
  end
end
