class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates_presence_of :title, :body
  validates_length_of :body, :maximum => 2000
end
