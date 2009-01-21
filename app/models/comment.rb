class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates_presence_of :title, :body
  validates_length_of :body, :maximum => 2000
end

# == Schema Information
# Schema version: 20090116200734
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  title            :string(255)
#  commentable_type :string(255)
#  commentable_id   :integer(4)
#  user_id          :integer(4)
#  body             :text
#  created_at       :datetime
#  updated_at       :datetime
#

