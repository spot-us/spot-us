class Post < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :user

  validates_presence_of :title, :body, :user, :pitch
end
