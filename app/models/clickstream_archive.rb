class ClickstreamArchive < ActiveRecord::Base

  belongs_to :clickstreamable, :polymorphic => true
  belongs_to :user

end
