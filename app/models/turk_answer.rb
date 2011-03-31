class TurkAnswer < ActiveRecord::Base
  
  belongs_to :taggable, :polymorphic => true
  belongs_to :cca
  
end
