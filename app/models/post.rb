class Post < ActiveRecord::Base
  belongs_to :pitch

  validates_presence_of :title, :body
end
