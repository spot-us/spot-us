class Tagging < ActiveRecord::Base
  
  belongs_to :taggable, :polymorphic => true
  has_many :tags
  has_many :normalized_tags
  
end
